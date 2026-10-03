require "rails_helper"

RSpec.describe Locker, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:physical_device) }
    it { is_expected.to belong_to(:company).optional }
    it { is_expected.to have_many(:locker_team_permissions) }
    it { is_expected.to have_many(:teams).through(:locker_team_permissions) }
    it { is_expected.to have_many(:locker_actions) }
  end

  describe "status enum" do
    it { is_expected.to define_enum_for(:status).with_values(closed: 0, open: 1) }
  end

  describe "unassigned helpers" do
    it "returns true for a locker with no company" do
      expect(build(:locker, :unassigned)).to be_unassigned
      expect(build(:locker, :unassigned)).not_to be_assigned
    end
  end

  describe "active vs. archived scopes" do
    it "active only returns contracts with ended_at: nil" do
      live     = create(:locker)
      archived = create(:locker, :archived)

      expect(Locker.active).to contain_exactly(live)
      expect(Locker.historical).to contain_exactly(archived)
    end
  end

  describe "DB-level invariants" do
    it "forbids two active contracts for the same physical device" do
      device = create(:physical_device)
      create(:locker, physical_device: device)
      duplicate = build(:locker, physical_device: device)

      expect { duplicate.save(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "allows a historical contract + a current contract on the same device" do
      device = create(:physical_device)
      create(:locker, :archived, physical_device: device)

      expect { create(:locker, physical_device: device) }.not_to raise_error
    end
  end

  describe "composite tenant integrity" do
    it "blocks a team permission that mixes companies" do
      amazon_locker = create(:locker, company: create(:company))
      dpd_team      = create(:team, company: create(:company))

      insert_sql = <<~SQL
        INSERT INTO locker_team_permissions
          (locker_id, team_id, company_id, created_at, updated_at)
        VALUES
          (#{amazon_locker.id}, #{dpd_team.id}, #{amazon_locker.company_id}, NOW(), NOW())
      SQL

      expect { ActiveRecord::Base.connection.execute(insert_sql) }
        .to raise_error(ActiveRecord::StatementInvalid)
    end
  end
end
