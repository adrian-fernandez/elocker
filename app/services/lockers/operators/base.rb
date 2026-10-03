module Lockers
  module Operators
    # Abstract command for operating a locker (open/close/future).
    #
    # Encapsulates the complete command cycle that every operation shares:
    #
    #   1. Authorize the user against the locker (same policy as `VisibleTo`).
    #   2. Validate the locker's current state (can't open an open locker).
    #   3. In a single DB transaction:
    #        a. Persist the user-triggered request action.
    #        b. Dispatch the command to the device via the injected API driver.
    #        c. Persist the device-reported response action and update the
    #           locker's status (only if the driver reports success).
    #
    # Subclasses declare which action symbols and final status apply via
    # three tiny template methods; nothing else changes. New operations
    # (unlock-and-hold, boot into service mode, etc.) are a new subclass.
    class Base < ApplicationService
      class NotAllowedError < StandardError; end
      class InvalidStateError < StandardError; end
      class DeviceError < StandardError; end

      def initialize(locker:, user:, api: nil, visibility: Lockers::VisibleTo)
        @locker = locker
        @user = user
        @api = api || Lockers::Api.for(locker:)
        @visibility = visibility
      end

      def call
        authorize!
        validate_state!

        # `requires_new: true` so a device failure rolls back the request
        # row via a savepoint, even if we're already inside a surrounding
        # transaction (test wrappers, user-code batches, etc.).
        ActiveRecord::Base.transaction(requires_new: true) do
          create_request!
          response = dispatch!
          raise DeviceError, response.message unless response.ok?

          apply_response!
        end

        @locker
      end

      private

      # Delegates authorization to the same scope that gates visibility, so
      # the "can operate" and "can see" policies cannot diverge.
      def authorize!
        return if @visibility.call(user: @user).exists?(id: @locker.id)

        raise NotAllowedError,
              "User ##{@user.id} is not allowed to operate locker ##{@locker.id}"
      end

      def validate_state!
        return if initial_state_valid?

        raise InvalidStateError,
              "Locker is already #{@locker.status}"
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

      # Subclass contract — four tiny template methods:
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
