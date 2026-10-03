# A Locker is a contract between a PhysicalDevice and a Company for a window
# of time. The current contract has ended_at = NULL; historical contracts are
# preserved as audit. company_id = NULL means "unassigned": the device is on
# the platform but not owned by any tenant yet — only platform-owner users
# see and operate it (useful for provisioning and self-test).
class Locker < ApplicationRecord
  belongs_to :physical_device
  belongs_to :company, optional: true
  belongs_to :last_status_changed_by,
             class_name: "User",
             optional: true

  has_many :locker_team_permissions
  has_many :teams, through: :locker_team_permissions

  has_many :locker_actions

  enum :status, {
    closed: 0,
    open: 1
  }

  # Current contracts (not yet transferred away).
  scope :active,     -> { where(ended_at: nil) }
  scope :historical, -> { where.not(ended_at: nil) }
  scope :assigned,   -> { where.not(company_id: nil) }
  scope :unassigned, -> { where(company_id: nil) }

  delegate :device_id, to: :physical_device, allow_nil: true

  def active?
    ended_at.nil?
  end

  def unassigned?
    company_id.nil?
  end

  def assigned?
    !unassigned?
  end

  after_update_commit  -> { broadcast_refresh_to "lockers" }
  after_create_commit  -> { broadcast_refresh_to "lockers" }
  after_destroy_commit -> { broadcast_refresh_to "lockers" }
end
