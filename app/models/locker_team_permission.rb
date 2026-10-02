class LockerTeamPermission < ApplicationRecord
  belongs_to :locker
  belongs_to :team
end
