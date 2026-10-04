class Team < ApplicationRecord
  belongs_to :company, counter_cache: :teams_count

  has_and_belongs_to_many :users

  has_many :locker_team_permissions
  has_many :lockers, through: :locker_team_permissions

  # DB has a unique index on (company_id, name) — the model validation
  # gives a friendly error instead of a PG::UniqueViolation.
  validates :name, presence: true, uniqueness: { scope: :company_id, case_sensitive: false }
end
