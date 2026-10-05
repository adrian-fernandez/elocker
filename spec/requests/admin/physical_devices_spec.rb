require "rails_helper"

RSpec.describe "Admin::PhysicalDevices", type: :request do
  let(:platform_user) { create(:user, :platform_owner) }

  before { patch "/session", params: {user_id: platform_user.id} }

  describe "GET /admin/physical_devices" do
    it "lists every device alongside the company that currently owns it" do
      amazon = create(:company, name: "Amazon")
      device_a = create(:physical_device, device_id: "DEV-9001")
      device_b = create(:physical_device, device_id: "DEV-9002")
      create(:locker, physical_device: device_a, company: amazon, name: "A1")
      create(:locker, physical_device: device_b, company: amazon, name: "A2")

      get "/admin/physical_devices"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("DEV-9001").and include("DEV-9002").and include("Amazon")
    end

    it "returns 403 to tenants" do
      tenant = create(:user)
      patch "/session", params: {user_id: tenant.id}

      get "/admin/physical_devices"

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /admin/physical_devices/:id" do
    it "renders the ownership history for a device" do
      device = create(:physical_device, device_id: "DEV-9002")
      create(:locker, :archived, physical_device: device, name: "old-contract")
      create(:locker, physical_device: device, name: "current-contract")

      get "/admin/physical_devices/#{device.id}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("DEV-9002")
        .and include("old-contract")
        .and include("current-contract")
    end
  end
end
