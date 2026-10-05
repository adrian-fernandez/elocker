require "rails_helper"

RSpec.describe LockersHelper, type: :helper do
  describe "#locker_status_badge" do
    it "renders the open badge when status is :open" do
      html = helper.locker_status_badge(:open)
      expect(html).to include("text-bg-success").and include("Open")
    end

    it "renders the closed badge when status is :closed" do
      html = helper.locker_status_badge(:closed)
      expect(html).to include("text-bg-secondary").and include("Closed")
    end

    it "adds fs-6 when size: :lg" do
      html = helper.locker_status_badge(:open, size: :lg)
      expect(html).to include("fs-6")
    end
  end

  describe "#locker_action_badge" do
    let(:locker) { create(:locker) }

    it "renders the plain action label for non-forced requests" do
      action = build(:locker_action, :open_request, locker:, forced: false)
      html = helper.locker_action_badge(action)
      expect(html).to include("Open requested")
    end

    it "renders the Force-prefixed label for forced requests" do
      action = build(:locker_action, :open_request, :forced, locker:)
      html = helper.locker_action_badge(action)
      expect(html).to include("Force Open requested")
    end

    it "renders device responses with the status palette (no force prefix)" do
      action = build(:locker_action, :opened, locker:)
      html = helper.locker_action_badge(action)
      expect(html).to include("text-bg-success").and include("Opened")
    end
  end

  describe "#locker_owner_badge" do
    it "returns the company name when assigned" do
      company = create(:company, name: "Amazon")
      locker  = build(:locker, company:)
      expect(helper.locker_owner_badge(locker)).to eq("Amazon")
    end

    it "renders the Unassigned badge otherwise" do
      locker = build(:locker, :unassigned)
      html = helper.locker_owner_badge(locker)
      expect(html).to include("badge").and include("Unassigned")
    end
  end

  describe "#linked_user_name" do
    let(:user) { create(:user, name: "Alice Johnson") }

    it "renders an admin link when linked: true" do
      html = helper.linked_user_name(user, linked: true)
      expect(html).to include(%(href="/admin/users/#{user.id}"))
      expect(html).to include("Alice Johnson")
    end

    it "renders escaped plain text when linked: false" do
      html = helper.linked_user_name(user, linked: false)
      expect(html).to eq("Alice Johnson")
      expect(html).not_to include("<a")
    end
  end
end
