require "rails_helper"

RSpec.describe LockerActions::Fetcher do
  describe ".call (end-to-end composition)" do
    let(:user) { create(:user, :platform_owner) }

    it "returns a CursorPagination of filtered + ordered actions" do
      locker = create(:locker)
      opened = create(:locker_action, :opened, locker: locker, company_id: locker.company_id, created_at: 1.hour.ago)
      req = create(:locker_action, :open_request, locker: locker, company_id: locker.company_id, created_at: 2.hours.ago)

      result = described_class.call(user: user, params: {})

      expect(result).to be_a(CursorPagination)
      expect(result.records.first).to eq(opened)
      expect(result.records.last).to eq(req)
    end

    it "applies filters via LockerActions::Filter" do
      locker = create(:locker)
      create(:locker_action, :opened, locker: locker, company_id: locker.company_id)
      create(:locker_action, :open_request, locker: locker, company_id: locker.company_id)

      result = described_class.call(user: user, params: {action_type: "opened"})
      expect(result.map(&:action)).to eq(["opened"])
    end

    it "paginates with a limit and exposes a next cursor" do
      locker = create(:locker)
      6.times { create(:locker_action, :opened, locker: locker, company_id: locker.company_id) }

      result = described_class.call(user: user, params: {per_page: 2})
      expect(result.size).to eq(2)
      expect(result).to have_next_page
      expect(result.next_cursor).to be_present
    end

    it "advances via cursor without duplicating records" do
      locker = create(:locker)
      actions = 5.times.map { |i|
        create(:locker_action, :opened, locker: locker, company_id: locker.company_id, created_at: i.minutes.ago)
      }

      page1 = described_class.call(user: user, params: {per_page: 2})
      page2 = described_class.call(user: user, params: {per_page: 2, cursor: page1.next_cursor})

      expect(page1.records.first).to eq(actions.first)
      expect(page2.records).not_to include(*page1.records)
    end
  end

  describe ".call (dependency injection)" do
    it "delegates to visibility, filter, and paginator" do
      user = create(:user, :platform_owner)
      visibility = class_double("LockerActions::VisibleTo")
      filter = class_double("LockerActions::Filter")
      paginator = class_double("CursorPagination")

      base = LockerAction.all
      filtered = LockerAction.where(id: 0)
      pagination = instance_double("CursorPagination")

      allow(visibility).to receive(:call).with(user: user).and_return(base)
      allow(filter).to receive(:call).with(hash_including(params: {x: 1})).and_return(filtered)
      allow(paginator).to receive(:from_params) { |_scope, _params| pagination }

      result = described_class.call(
        user: user,
        params: {x: 1},
        visibility: visibility,
        filter: filter,
        paginator: paginator
      )

      expect(result).to eq(pagination)
    end
  end
end
