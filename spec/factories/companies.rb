FactoryBot.define do
  factory :company do
    sequence(:name) { |n| "Company #{n}" }
    platform_owner { false }

    # Trait name intentionally differs from the `platform_owner` column so
    # factory_bot doesn't treat the trait as an attribute override.
    trait :platform do
      name { "eLocker" }
      platform_owner { true }
    end
  end
end
