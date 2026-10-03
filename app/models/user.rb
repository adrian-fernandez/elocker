class User < ApplicationRecord
  belongs_to :company

  has_and_belongs_to_many :teams
  has_many :locker_actions
end
