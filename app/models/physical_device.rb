# The hardware. A PhysicalDevice has a stable `device_id` (what's printed on
# the sticker) and lives through zero or more `Locker` contracts over time.
# eLocker ops provisions a device by registering it here, which creates its
# first (unassigned) Locker row. Transferring a device to a tenant closes the
# current contract and opens a new one.
class PhysicalDevice < ApplicationRecord
  # No default scope on the association: counts, `exists?`, etc. shouldn't
  # pay for a sort they don't need. Callers that want chronological order
  # use the explicit association scope below.
  has_many :lockers, dependent: :restrict_with_exception
  has_many :lockers_newest_first,
           -> { order(started_at: :desc) },
           class_name: "Locker",
           inverse_of: :physical_device

  validates :device_id, presence: true, uniqueness: true

  # The current (open-ended) Locker contract, if any. DB enforces at most
  # one thanks to the partial unique index on (physical_device_id) WHERE
  # ended_at IS NULL. Reuses the already-loaded association when the caller
  # eager-loaded `:lockers`; otherwise runs a scoped query.
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
