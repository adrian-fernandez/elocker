class Team < ApplicationRecord
  belongs_to :company

  has_and_belongs_to_many :users

  has_many :locker_team_permissions
  has_many :lockers, through: :locker_team_permissions
end
