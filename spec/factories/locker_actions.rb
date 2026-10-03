FactoryBot.define do
  factory :locker_action do
    locker
    # Pick a sensible default actor: tenant-owned locker gets a tenant user,
    # unassigned locker gets a platform-owner user. Specs can override.
    user do
      if locker.company
        build(:user, company: locker.company)
      else
        build(:user, :platform_owner)
      end
    end
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
