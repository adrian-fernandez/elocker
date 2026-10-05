require "rails_helper"

RSpec.describe "Lockers operations", type: :request do
  let(:company) { create(:company) }
  let(:locker)  { create(:locker, company:, status: :closed) }

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
      expect(flash[:alert]).to include('already open')
    end
  end

  describe "POST /lockers/:id/force_close (force path)" do
    it "succeeds even when the locker's app state is already closed" do
      support = create(:user, :platform_owner)
      login_as(support)

      post "/lockers/#{locker.id}/force_close"

      expect(response).to redirect_to(locker_path(locker))
      expect(flash[:notice]).to include('Device command sent')
    end
  end

  describe "POST /lockers/:id/force_open (force path)" do
    it "succeeds and transitions to open even when the state already matches" do
      support = create(:user, :platform_owner)
      login_as(support)
      locker.update!(status: :open)

      post "/lockers/#{locker.id}/force_open"

      expect(response).to redirect_to(locker_path(locker))
      expect(locker.reload).to be_open
      expect(flash[:notice]).to include('Device command sent')
    end
  end

  describe "when the device driver reports a failure" do
    it "redirects with the translated device-error flash" do
      support = create(:user, :platform_owner)
      login_as(support)

      failing_response = Lockers::Api::Response.new(ok: false, message: "timeout")
      allow(Lockers::Api).to receive(:for).and_return(
        instance_double(Lockers::Api::Mock, open: failing_response)
      )

      post "/lockers/#{locker.id}/open"

      expect(response).to redirect_to(locker_path(locker.id))
      expect(flash[:alert]).to include("timeout")
    end
  end

  describe "when the operator rejects authorization at its own layer" do
    it "renders the forbidden page via the shared rescue_from" do
      support = create(:user, :platform_owner)
      login_as(support)

      allow(Lockers::Operators::Open).to receive(:call)
        .and_raise(Lockers::Operators::Base::NotAllowedError, "nope")

      post "/lockers/#{locker.id}/open"

      expect(response).to have_http_status(:forbidden)
      expect(response.body).to include("Access denied")
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
