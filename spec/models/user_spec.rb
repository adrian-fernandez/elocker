require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to have_and_belong_to_many(:teams) }
    it { is_expected.to have_many(:locker_actions) }
  end

  describe "#platform_owner?" do
    it "delegates to its company" do
      platform_user = create(:user, :platform_owner)
      tenant_user   = create(:user)

      expect(platform_user).to be_platform_owner
      expect(tenant_user).not_to be_platform_owner
    end
  end

  describe "composite tenant integrity" do
    it "blocks a user from joining a team of another company" do
      amazon = create(:company)
      dpd    = create(:company)
      alice  = create(:user, company: amazon)
      drivers = create(:team, company: dpd)

      insert_sql = <<~SQL
        INSERT INTO teams_users (user_id, team_id, company_id)
        VALUES (#{alice.id}, #{drivers.id}, #{amazon.id})
      SQL

      expect { ActiveRecord::Base.connection.execute(insert_sql) }
        .to raise_error(ActiveRecord::StatementInvalid)
    end
  end
end
