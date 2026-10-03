require "rails_helper"

RSpec.describe Locker, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to have_many(:locker_team_permissions) }
    it { is_expected.to have_many(:teams).through(:locker_team_permissions) }
    it { is_expected.to have_many(:locker_actions) }
  end

  describe "status enum" do
    it { is_expected.to define_enum_for(:status).with_values(closed: 0, open: 1) }
  end

  describe "device_id uniqueness" do
    it "is globally unique across companies" do
      create(:locker, device_id: "AMZ-001", company: create(:company))
      duplicate = build(:locker, device_id: "AMZ-001", company: create(:company))

      expect { duplicate.save(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique)
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
