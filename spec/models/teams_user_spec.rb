require "rails_helper"

RSpec.describe TeamsUser, type: :model do
  describe "uniqueness on (team_id, user_id)" do
    it "forbids duplicate memberships" do
      company = create(:company)
      team = create(:team, company:)
      user = create(:user, company:)
      create(:teams_user, team:, user:, company_id: company.id)

      duplicate_sql = <<~SQL
        INSERT INTO teams_users (user_id, team_id, company_id)
        VALUES (#{user.id}, #{team.id}, #{company.id})
      SQL

      expect { ActiveRecord::Base.connection.execute(duplicate_sql) }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
