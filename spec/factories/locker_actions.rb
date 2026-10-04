FactoryBot.define do
  factory :locker_action do
    locker
    company_id { locker.company_id }
    action { :open_request }
    user { build(:user, company: locker.company || create(:company)) }

    trait :open_request do
      action { :open_request }
    end

    trait :close_request do
      action { :close_request }
    end

    trait :opened do
      action { :opened }
      user { nil }
    end

    trait :closed do
      action { :closed }
      user { nil }
    end

    trait :by_platform_owner do
      user { build(:user, :platform_owner) }
    end
  end
end
