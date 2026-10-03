FactoryBot.define do
  factory :physical_device do
    sequence(:device_id) { |n| "DEV-#{n.to_s.rjust(4, '0')}" }
    model { "SmartLock-24" }
  end
end
