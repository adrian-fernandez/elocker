FactoryBot.define do
  factory :locker_team_permission do
    # The composite FKs (locker_id, company_id) and (team_id, company_id)
    # require both locker and team to belong to the same company. Callers
    # should pass a shared company explicitly in most tests.
    locker
    team { build(:team, company: locker.company) }
    company_id { locker.company_id }

    # Deliberately wrong — a team in a different company. Useful to drive
    # negative tests that confirm the composite FKs actually reject it.
    trait :cross_company do
      team { build(:team, company: create(:company)) }
    end
  end
end
