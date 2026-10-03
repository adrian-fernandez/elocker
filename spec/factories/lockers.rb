FactoryBot.define do
  factory :locker do
    sequence(:name) { |n| "Locker #{n}" }
    sequence(:device_id) { |n| "DEV-#{n.to_s.rjust(4, '0')}" }
    company
    status { :closed }
  end
end
