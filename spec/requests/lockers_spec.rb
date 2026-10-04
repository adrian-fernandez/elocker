require "rails_helper"

RSpec.describe "Lockers operations", type: :request do
  let(:company) { create(:company) }
  let(:locker)  { create(:locker, company: company, status: :closed) }

  def login_as(user)
    patch "/session", params: {user_id: user.id}
  end

  describe "POST /lockers/:id/open" do
    it "returns 404 when the locker is not visible to the user" do
      stranger = create(:user)
      login_as(stranger)

      post "/lockers/#{locker.id}/open"

      expect(response).to have_http_status(:not_found)
    end

    it "redirects to the show on success and transitions the locker" do
      support = create(:user, :platform_owner)
      login_as(support)

      post "/lockers/#{locker.id}/open"

      expect(response).to redirect_to(locker_path(locker))
      expect(locker.reload).to be_open
    end

    it "redirects with alert when the locker is already in the target state" do
      locker.update!(status: :open)
      support = create(:user, :platform_owner)
      login_as(support)

      post "/lockers/#{locker.id}/open"

      expect(response).to redirect_to(locker_path(locker.id))
      expect(flash[:alert]).to match(/already open/)
    end
  end

  describe "POST /lockers/:id/force_close (force path)" do
    it "succeeds even when the locker's app state is already closed" do
      support = create(:user, :platform_owner)
      login_as(support)

      post "/lockers/#{locker.id}/force_close"

      expect(response).to redirect_to(locker_path(locker))
      expect(flash[:notice]).to match(/Device command sent/)
    end
  end

  describe "POST /admin/lockers/:id/open" do
    it "returns 403 Forbidden to tenants hitting admin operations" do
      tenant = create(:user)
      login_as(tenant)

      post "/admin/lockers/#{locker.id}/open"

      expect(response).to have_http_status(:forbidden)
    end
  end
end
