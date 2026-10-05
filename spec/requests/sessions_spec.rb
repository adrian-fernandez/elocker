require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "PATCH /session" do
    it "switches the current user and redirects back to the previous page" do
      alice = create(:user, name: "Alice")
      bob   = create(:user, name: "Bob")
      patch "/session", params: {user_id: alice.id}

      patch "/session", params: {user_id: bob.id}, headers: {"HTTP_REFERER" => "/lockers"}

      expect(response).to redirect_to("/lockers")
      expect(session[:user_id]).to eq(bob.id)
      follow_redirect!
      expect(flash[:notice]).to include("Bob")
    end
  end

  describe "GET /switcher/users" do
    it "renders tenant and platform users, with the platform-owner company before any tenant" do
      platform = create(:user, :platform_owner, name: "Platform Admin")
      amazon   = create(:company, name: "Amazon")
      create(:user, name: "Alice Johnson", company: amazon)

      get "/switcher/users"

      expect(response).to have_http_status(:ok)
      body = response.body
      expect(body).to include("Platform Admin").and include("Alice Johnson")
      expect(body.index(platform.company.name)).to be < body.index("Amazon")
    end
  end
end
