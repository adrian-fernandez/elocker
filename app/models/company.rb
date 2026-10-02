class Company < ApplicationRecord
  has_many :users
  has_many :teams
  has_many :lockers
end
