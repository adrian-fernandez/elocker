# A Locker is a contract between a PhysicalDevice and a Company for a window
# of time. The current contract has ended_at = NULL; historical contracts are
# preserved as audit. company_id = NULL means "unassigned": the device is on
# the platform but not owned by any tenant yet — only platform-owner users
# see and operate it (useful for provisioning and self-test).
class Locker < ApplicationRecord
  belongs_to :physical_device
  belongs_to :company, optional: true, counter_cache: :lockers_count
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

  validates :name, presence: true
  validates :started_at, presence: true
  validate :ended_at_after_started_at
  validate :company_is_tenant

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

  private

  def ended_at_after_started_at
    return if ended_at.nil? || started_at.nil?
    return if ended_at > started_at

    errors.add(:ended_at, "must be after started_at")
  end

  # A Locker contract represents a tenant owning a device. The platform-
  # owner company (eLocker) can never be a Locker's owner — platform acts
  # on unassigned (NULL) lockers via its elevated role instead. Protects
  # against UI-bypassing POSTs that would silently point a locker at the
  # eLocker company.
  def company_is_tenant
    return if company.nil?
    return unless company.platform_owner

    errors.add(:company, "cannot be the platform owner")
  end
end
