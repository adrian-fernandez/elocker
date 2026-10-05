require "rails_helper"

RSpec.describe "Admin::Users", type: :request do
  describe "GET /admin/users" do
    it "lists every user with their company" do
      platform_user = create(:user, :platform_owner)
      amazon        = create(:company, name: "Amazon")
      create(:user, name: "Alice Johnson", company: amazon)
      patch "/session", params: {user_id: platform_user.id}

      get "/admin/users"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Alice Johnson").and include("Amazon")
    end
  end

  describe "GET /admin/users/:id" do
    it "renders the user detail page for a platform owner" do
      platform_user = create(:user, :platform_owner)
      target        = create(:user, name: "Alice Johnson")
      patch "/session", params: {user_id: platform_user.id}

      get "/admin/users/#{target.id}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Alice Johnson")
    end

    it "returns 403 Forbidden to tenants hitting the admin section" do
      tenant = create(:user)
      target = create(:user)
      patch "/session", params: {user_id: tenant.id}

      get "/admin/users/#{target.id}"

      expect(response).to have_http_status(:forbidden)
      expect(response.body).to include("Access denied")
    end
  end
end
