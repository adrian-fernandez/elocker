FactoryBot.define do
  factory :teams_user do
    team
    user { build(:user, company: team.company) }
    company_id { team.company_id }
  end
end
