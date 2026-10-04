# The hardware. A PhysicalDevice has a stable `device_id` and lives through
# zero or more `Locker` contracts over time. Provisioning registers one;
# transferring to a tenant archives the current contract and opens a new one.
class PhysicalDevice < ApplicationRecord
  # Default association has no order so counts, `exists?`, etc. don't pay
  # for a sort. Chronological callers use `lockers_newest_first`.
  has_many :lockers, dependent: :restrict_with_exception
  has_many :lockers_newest_first,
           -> { order(started_at: :desc) },
           class_name: "Locker",
           inverse_of: :physical_device

  validates :device_id, presence: true, uniqueness: true

  def current_locker
    if association(:lockers).loaded?
      lockers.detect { |l| l.ended_at.nil? }
    else
      lockers.find_by(ended_at: nil)
    end
  end

  def historical_lockers
    lockers.where.not(ended_at: nil)
  end
end
