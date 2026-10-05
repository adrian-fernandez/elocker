require "rails_helper"

RSpec.describe "Admin::Lockers", type: :request do
  let(:platform_user) { create(:user, :platform_owner) }

  before { patch "/session", params: {user_id: platform_user.id} }

  describe "GET /admin/lockers" do
    it "renders active lockers from every tenant and omits archived contracts" do
      amazon = create(:company, name: "Amazon")
      dpd    = create(:company, name: "DPD")
      create(:locker, company: amazon, name: "A1")
      create(:locker, company: dpd, name: "D1")
      create(:locker, :archived, company: amazon, name: "ARCHIVED-OLD")

      get "/admin/lockers"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("A1").and include("D1")
      expect(response.body).not_to include("ARCHIVED-OLD")
    end

    it "returns 403 to tenants" do
      tenant = create(:user)
      patch "/session", params: {user_id: tenant.id}

      get "/admin/lockers"

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /admin/lockers/:id" do
    it "renders the locker detail including its recent activity" do
      amazon = create(:company, name: "Amazon")
      locker = create(:locker, company: amazon, name: "A1")
      create(:locker_action, :open_request, locker:, company_id: amazon.id)

      get "/admin/lockers/#{locker.id}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("A1").and include("Open requested")
    end
  end
end
