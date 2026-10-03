class LockerAction < ApplicationRecord
  belongs_to :locker
  belongs_to :user, optional: true
  belongs_to :company

  enum :action, {
    open_request: 0,
    close_request: 1,
    opened: 2,
    closed: 3
  }

  after_create_commit -> { broadcast_refresh_to "lockers" }
end
