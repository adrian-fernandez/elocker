require "rails_helper"

RSpec.describe "Admin locker transfer", type: :request do
  let(:platform_user) { create(:user, :platform_owner) }
  let(:elocker)       { platform_user.company }
  let(:amazon)        { create(:company, name: "Amazon") }

  before { patch "/session", params: {user_id: platform_user.id} }

  describe "GET /admin/lockers/:id/transfer" do
    it "renders the transfer form for the current contract" do
      locker = create(:locker, company: amazon)

      get "/admin/lockers/#{locker.id}/transfer"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Transfer")
    end

    it "excludes the current company from the target dropdown" do
      dpd    = create(:company, name: "DPD")
      locker = create(:locker, company: amazon)

      get "/admin/lockers/#{locker.id}/transfer"

      # Current owner must not be a target option (nothing to transfer
      # when "new" == "current").
      expect(response.body).not_to match(/<option value="#{amazon.id}">Amazon/)
      expect(response.body).to     match(/<option value="#{dpd.id}">DPD/)
    end

    it "shows the Unassign card only for assigned lockers" do
      assigned   = create(:locker, company: amazon)
      unassigned = create(:locker, :unassigned)

      get "/admin/lockers/#{assigned.id}/transfer"
      expect(response.body).to include("Return to the unassigned pool")

      get "/admin/lockers/#{unassigned.id}/transfer"
      expect(response.body).not_to include("Return to the unassigned pool")
    end
  end

  describe "POST /admin/lockers/:id/transfer" do
    it "transfers an unassigned locker to a tenant and redirects to the new locker" do
      device = create(:physical_device, device_id: "SPARE-X")
      current = create(:locker, :unassigned, physical_device: device, name: "SPARE-X")

      post "/admin/lockers/#{current.id}/transfer",
           params: {company_id: amazon.id, name: "Amazon X"}

      expect(response).to redirect_to(/\/admin\/lockers\/\d+/)
      new_locker = device.lockers.find_by(ended_at: nil)
      expect(new_locker).to be_present
      expect(new_locker.company).to eq(amazon)
      expect(new_locker.name).to eq("Amazon X")
      expect(current.reload.ended_at).to be_present
    end

    it "treats a blank company_id as unassign" do
      locker = create(:locker, company: amazon, name: "A1")

      post "/admin/lockers/#{locker.id}/transfer",
           params: {company_id: "", name: "A1-returned"}

      expect(response).to be_redirect
      new_locker = locker.physical_device.lockers.find_by(ended_at: nil)
      expect(new_locker).to be_unassigned
    end

    it "rejects the platform-owner company as a target" do
      locker = create(:locker, company: amazon)

      post "/admin/lockers/#{locker.id}/transfer",
           params: {company_id: elocker.id, name: "ptfm"}

      # The controller scopes `Company.where(platform_owner: false).find(...)`
      # so an attempt to point a locker at eLocker raises RecordNotFound,
      # which Rails handles as 404.
      expect(response).to have_http_status(:not_found)
    end

    it "re-renders the form with alert on validation errors" do
      locker = create(:locker, company: amazon, name: "A1")

      post "/admin/lockers/#{locker.id}/transfer",
           params: {company_id: amazon.id, name: "A1"}

      expect(response).to redirect_to(transfer_admin_locker_path(locker))
      follow_redirect!
      expect(flash[:alert]).to match(/Nothing to transfer/)
    end

    it "returns 403 to tenants" do
      tenant = create(:user)
      patch "/session", params: {user_id: tenant.id}

      locker = create(:locker, company: amazon)
      post "/admin/lockers/#{locker.id}/transfer", params: {company_id: amazon.id, name: "x"}

      expect(response).to have_http_status(:forbidden)
    end
  end
end
