require "rails_helper"

RSpec.describe Teams::Fetcher do
  describe ".call" do
    it "returns a Pagination with filtered records" do
      amazon = create(:company)
      warehouse = create(:team, name: "Warehouse", company: amazon)
      create(:team, name: "Drivers")

      result = described_class.call(params: { name: "ware", company_id: amazon.id })

      expect(result).to be_a(Pagination)
      expect(result.records).to contain_exactly(warehouse)
    end
  end
end
