require "rails_helper"

RSpec.describe LockerActions::Fetcher do
  describe ".call (end-to-end composition)" do
    let(:user) { create(:user, :platform_owner) }

    it "returns a Pagination of filtered + ordered actions" do
      locker = create(:locker)
      opened = create(:locker_action, :opened, locker: locker, company_id: locker.company_id, created_at: 1.hour.ago)
      req    = create(:locker_action, :open_request, locker: locker, company_id: locker.company_id, created_at: 2.hours.ago)

      result = described_class.call(user: user, params: {})

      expect(result).to be_a(Pagination)
      expect(result.records.first).to eq(opened) # ordered DESC by created_at
      expect(result.records.last).to  eq(req)
    end

    it "applies filters via LockerActions::Filter" do
      locker = create(:locker)
      create(:locker_action, :opened, locker: locker, company_id: locker.company_id)
      create(:locker_action, :open_request, locker: locker, company_id: locker.company_id)

      result = described_class.call(user: user, params: { action_type: "opened" })
      expect(result.map(&:action)).to eq(["opened"])
    end

    it "paginates" do
      locker = create(:locker)
      6.times { create(:locker_action, :opened, locker: locker, company_id: locker.company_id) }

      result = described_class.call(user: user, params: { per_page: 2 })
      expect(result.size).to eq(2)
      expect(result.total).to eq(6)
    end
  end

  describe ".call (dependency injection)" do
    it "delegates to visibility, filter, and paginator" do
      user = create(:user, :platform_owner)

      visibility = class_double("LockerActions::VisibleTo")
      filter     = class_double("LockerActions::Filter")
      paginator  = class_double("Pagination")

      base       = LockerAction.all
      filtered   = LockerAction.where(id: 0)
      pagination = instance_double("Pagination")

      allow(visibility).to receive(:call).with(user: user).and_return(base)
      allow(filter).to receive(:call).with(hash_including(params: { x: 1 })).and_return(filtered)
      allow(paginator).to receive(:from_params) { |_scope, _params| pagination }

      result = described_class.call(
        user: user,
        params: { x: 1 },
        visibility: visibility,
        filter: filter,
        paginator: paginator
      )

      expect(result).to eq(pagination)
    end
  end
end
