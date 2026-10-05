require "rails_helper"

RSpec.describe LockerTeamPermission, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:locker) }
    it { is_expected.to belong_to(:team) }
  end

  describe "uniqueness on (locker_id, team_id)" do
    it "forbids duplicate grants" do
      company = create(:company)
      locker  = create(:locker, company:)
      team    = create(:team, company:)

      create(:locker_team_permission, locker:, team:, company_id: company.id)
      duplicate = build(:locker_team_permission, locker:, team:, company_id: company.id)

      expect { duplicate.save(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
