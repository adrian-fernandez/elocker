require "rails_helper"

RSpec.describe "Activity", type: :request do
  describe "GET /activity" do
    it "renders every action for a platform owner" do
      platform = create(:user, :platform_owner)
      amazon_locker = create(:locker)
      dpd_locker    = create(:locker)
      create(:locker_action, :opened, locker: amazon_locker, company_id: amazon_locker.company_id)
      create(:locker_action, :opened, locker: dpd_locker,    company_id: dpd_locker.company_id)

      patch "/session", params: { user_id: platform.id }
      get "/activity"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(amazon_locker.name)
      expect(response.body).to include(dpd_locker.name)
    end

    it "scopes to the tenant's accessible lockers" do
      amazon = create(:company)
      user   = create(:user, company: amazon)
      team   = create(:team, company: amazon)
      create(:teams_user, user: user, team: team, company_id: amazon.id)

      visible_locker = create(:locker, company: amazon)
      create(:locker_team_permission, locker: visible_locker, team: team, company_id: amazon.id)

      hidden_locker  = create(:locker, company: amazon)  # same company, no permission

      create(:locker_action, :opened, locker: visible_locker, company_id: amazon.id)
      create(:locker_action, :opened, locker: hidden_locker,  company_id: amazon.id)

      patch "/session", params: { user_id: user.id }
      get "/activity"

      expect(response.body).to include(visible_locker.name)
      expect(response.body).not_to include(hidden_locker.name)
    end
  end
end
