require "rails_helper"

RSpec.describe Team, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to have_and_belong_to_many(:users) }
    it { is_expected.to have_many(:locker_team_permissions) }
    it { is_expected.to have_many(:lockers).through(:locker_team_permissions) }
  end

  describe "uniqueness" do
    it "forbids duplicate team names within one company" do
      company = create(:company)
      create(:team, name: "Warehouse", company:)
      duplicate = build(:team, name: "Warehouse", company:)

      expect { duplicate.save(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "allows the same team name across different companies" do
      create(:team, name: "Operations", company: create(:company))
      expect { create(:team, name: "Operations", company: create(:company)) }
        .not_to raise_error
    end
  end
end
