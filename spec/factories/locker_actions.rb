FactoryBot.define do
  factory :locker_action do
    locker
    user { build(:user, company: locker.company) }
    company_id { locker.company_id }
    action { :open_request }

    trait :open_request do
      action { :open_request }
    end

    trait :close_request do
      action { :close_request }
    end

    trait :opened do
      user { nil }
      action { :opened }
    end

    trait :closed do
      user { nil }
      action { :closed }
    end
  end
end
