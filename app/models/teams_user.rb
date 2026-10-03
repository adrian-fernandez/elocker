class TeamsUser < ApplicationRecord
  self.table_name = "teams_users"

  belongs_to :team
  belongs_to :user
  belongs_to :company
end
