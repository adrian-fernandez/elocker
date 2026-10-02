class Locker < ApplicationRecord
  belongs_to :company

  has_many :locker_team_permissions
  has_many :teams, through: :locker_team_permissions

  has_many :locker_actions

  enum :status, {
    closed: 0,
    open: 1
  }

  after_update_commit  -> { broadcast_refresh_to "lockers" }
  after_create_commit  -> { broadcast_refresh_to "lockers" }
  after_destroy_commit -> { broadcast_refresh_to "lockers" }
end
