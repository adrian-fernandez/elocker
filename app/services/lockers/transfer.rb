module Lockers
  # Transfers a physical device's ownership to a new company (or to the
  # unassigned pool). Immutable-contract model: the current Locker row is
  # closed by setting `ended_at`, and a brand-new Locker row is created for
  # the new owner. All historical audit (actions, previous permissions) stays
  # pinned to the archived Locker row — never rewritten.
  #
  # company: nil puts the device back in the unassigned pool (platform-only).
  #
  # Authorization lives in the controller (`require_platform_owner!`).
  # Keeping the policy decision there avoids threading a user/token through
  # every call site, mirroring how `Lockers::Operators::*` relies on the
  # controller's `scope.find` for the first visibility check.
  class Transfer < ApplicationService
    class InvalidTransferError < StandardError; end

    def initialize(physical_device:, company:, name:, at: Time.current)
      @physical_device = physical_device
      @company = company
      @name = name.to_s.squish
      @at = at
    end

    # Returns the newly-opened Locker contract.
    def call
      validate_blank_name!

      ActiveRecord::Base.transaction(requires_new: true) do
        # Serialise concurrent transfers per device. Without this lock, two
        # transfers racing on the same device could both find no active
        # contract (because the first archived it) and both create a new
        # one, violating the partial unique index on physical_device_id.
        @physical_device.lock!

        current = @physical_device.lockers.find_by(ended_at: nil)
        validate_not_noop!(current)
        close_current!(current) if current
        open_new!
      end
    end

    private

    def validate_blank_name!
      return if @name.present?

      raise InvalidTransferError, "Name is required"
    end

    def validate_not_noop!(current)
      return if current.nil?
      return unless current.company_id == @company&.id
      return unless current.name == @name

      raise InvalidTransferError,
            "Nothing to transfer — the device is already owned by this " \
            "company with that name"
    end

    def close_current!(current)
      # Permissions belong to the outgoing contract and must not survive
      # into the new tenant's world. Hard-delete via a scoped query so
      # the NOT NULL on locker_id is respected (the default `delete_all`
      # on the has_many would try to NULL the FK).
      LockerTeamPermission.where(locker_id: current.id).delete_all
      current.update!(ended_at: @at)
    end

    def open_new!
      Locker.create!(
        physical_device: @physical_device,
        company: @company,
        name: @name,
        status: :closed,
        started_at: @at
      )
    end
  end
end
