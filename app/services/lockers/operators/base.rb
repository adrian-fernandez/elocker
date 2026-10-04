module Lockers
  module Operators
    # Abstract command for operating a locker. Encapsulates the complete
    # cycle every operation shares: authorize, state-validate, persist a
    # request action, dispatch to the device driver, persist the response
    # action, update the locker status. Subclasses declare the specific
    # action symbols + driver command via template methods.
    class Base < ApplicationService
      class NotAllowedError < StandardError; end
      class InvalidStateError < StandardError; end
      class DeviceError < StandardError; end

      # force: true dispatches the command even if the locker's app-side
      # state already matches the target. Used to re-sync when the DB is
      # out of step with the physical device (missed response, network
      # glitch, etc.).
      def initialize(locker:, user:, api: nil, visibility: Lockers::VisibleTo, force: false)
        @locker = locker
        @user = user
        @api = api || Lockers::Api.for(locker:)
        @visibility = visibility
        @force = force
      end

      def call
        authorize!

        # requires_new: a device failure must roll back the request row
        # via a savepoint, even if the caller already opened a transaction.
        ActiveRecord::Base.transaction(requires_new: true) do
          # SELECT ... FOR UPDATE serialises concurrent operate attempts
          # on the same locker: the second one blocks, re-reads status,
          # and fails validate_state! if the first one already landed.
          @locker.lock!

          validate_state!
          create_request!
          response = dispatch!
          raise DeviceError, response.message unless response.ok?

          apply_response!
        end

        @locker
      end

      private

      # "Can operate" delegates to the same scope that gates "can see", so
      # the two policies cannot diverge.
      def authorize!
        return if @visibility.call(user: @user).exists?(id: @locker.id)

        raise NotAllowedError,
              "User ##{@user.id} is not allowed to operate locker ##{@locker.id}"
      end

      def validate_state!
        return if @force
        return if initial_state_valid?

        raise InvalidStateError, "Locker is already #{@locker.status}"
      end

      def create_request!
        LockerAction.create!(
          locker: @locker,
          user: @user,
          company: @locker.company,
          action: request_action
        )
      end

      def apply_response!
        LockerAction.create!(
          locker: @locker,
          user: nil,
          company: @locker.company,
          action: response_action
        )
        @locker.update!(
          status: final_status,
          last_status_changed_at: Time.current,
          last_status_changed_by: @user
        )
      end

      def dispatch!
        @api.public_send(driver_command)
      end

      def initial_state_valid?
        raise NotImplementedError
      end

      def request_action
        raise NotImplementedError
      end

      def response_action
        raise NotImplementedError
      end

      def driver_command
        raise NotImplementedError
      end

      def final_status
        raise NotImplementedError
      end
    end
  end
end
