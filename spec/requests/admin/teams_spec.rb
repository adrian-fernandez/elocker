require "rails_helper"

RSpec.describe "Admin::Teams", type: :request do
  let(:platform_user) { create(:user, :platform_owner) }

  before { patch "/session", params: {user_id: platform_user.id} }

  describe "GET /admin/teams" do
    it "lists every team across tenants" do
      amazon = create(:company, name: "Amazon")
      create(:team, name: "Warehouse", company: amazon)

      get "/admin/teams"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Warehouse").and include("Amazon")
    end

    it "returns 403 to tenants" do
      tenant = create(:user)
      patch "/session", params: {user_id: tenant.id}

      get "/admin/teams"

      expect(response).to have_http_status(:forbidden)
    end
  end
end
