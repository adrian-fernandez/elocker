require "rails_helper"

RSpec.describe Lockers::Fetcher do
  let(:user) { create(:user, :platform_owner) }

  describe ".call (end-to-end composition)" do
    before do
      create(:locker, name: "A1", status: :open)
      create(:locker, name: "A2", status: :closed)
    end

    it "returns a Pagination with the filtered + ordered records" do
      result = described_class.call(user: user, params: { status: "open" })

      expect(result).to be_a(Pagination)
      expect(result.records.map(&:name)).to eq(["A1"])
    end

    it "eager-loads the requested associations" do
      result = described_class.call(user: user, params: {}, includes: [:company])
      locker = result.records.first

      expect(locker.association(:company).loaded?).to be true
    end

    it "applies pagination from params" do
      5.times { |i| create(:locker, name: "L#{i}", status: :open) }

      result = described_class.call(user: user, params: { per_page: 2, page: 1 })
      expect(result.per_page).to eq(2)
      expect(result.records.size).to eq(2)
    end
  end

  describe ".call (dependency injection)" do
    it "delegates to visibility, filter, and paginator in order" do
      visibility = class_double("Lockers::VisibleTo")
      filter     = class_double("Lockers::Filter")
      paginator  = class_double("Pagination")

      base_scope     = Locker.all
      filtered_scope = Locker.where(id: 0)
      pagination_obj = instance_double("Pagination")

      allow(visibility).to receive(:call).with(user: user).and_return(base_scope)
      allow(filter).to receive(:call).with(scope: base_scope, params: { x: 1 }).and_return(filtered_scope)
      allow(paginator).to receive(:from_params) { |scope, _params| pagination_obj }

      result = described_class.call(
        user: user,
        params: { x: 1 },
        visibility: visibility,
        filter: filter,
        paginator: paginator
      )

      expect(result).to eq(pagination_obj)
      expect(visibility).to have_received(:call)
      expect(filter).to have_received(:call)
      expect(paginator).to have_received(:from_params)
    end
  end
end
