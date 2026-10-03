FactoryBot.define do
  factory :locker do
    sequence(:name) { |n| "Locker #{n}" }
    physical_device
    company
    status { :closed }
    started_at { Time.current }
    ended_at { nil }

    trait :unassigned do
      company { nil }
    end

    trait :archived do
      ended_at { Time.current }
    end
  end
end
