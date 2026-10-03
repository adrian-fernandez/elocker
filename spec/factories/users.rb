FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    company

    trait :platform_owner do
      company { association(:company, :platform) }
    end
  end
end
