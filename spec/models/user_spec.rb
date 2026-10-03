require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:company) }
    it { is_expected.to have_and_belong_to_many(:teams) }
    it { is_expected.to have_many(:locker_actions) }
  end

  # Note: the policy "is this user elevated?" lives in
  # Users::PlatformOwnerChecker, not here. The User model intentionally
  # does NOT expose a platform_owner? predicate so call sites can't
  # couple to the current implementation (company-based) and will have
  # to update if the policy evolves (per-user flag, roles, etc.).
  it "does not expose a platform_owner? predicate" do
    expect(described_class.instance_methods).not_to include(:platform_owner?)
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
