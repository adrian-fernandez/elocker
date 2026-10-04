class User < ApplicationRecord
  belongs_to :company, counter_cache: :users_count

  has_and_belongs_to_many :teams
  has_many :locker_actions

  validates :name, presence: true
end
