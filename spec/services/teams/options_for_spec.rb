require "rails_helper"

RSpec.describe Teams::OptionsFor do
  describe ".call" do
    let!(:amazon) { create(:company, name: "Amazon") }
    let!(:dpd)    { create(:company, name: "DPD") }
    let!(:amazon_warehouse) { create(:team, name: "Warehouse", company: amazon) }
    let!(:amazon_managers)  { create(:team, name: "Managers",  company: amazon) }
    let!(:dpd_drivers)      { create(:team, name: "Drivers",   company: dpd) }

    context "without a company filter" do
      it "returns every team, ordered by company then team name" do
        result = described_class.call(company_id: nil)
        expect(result.map(&:name)).to eq(["Managers", "Warehouse", "Drivers"])
      end
    end

    context "with a company filter" do
      it "returns only that company's teams" do
        result = described_class.call(company_id: amazon.id)
        expect(result).to contain_exactly(amazon_warehouse, amazon_managers)
      end

      it "ignores blank values" do
        result = described_class.call(company_id: "")
        expect(result.count).to eq(3)
      end
    end
  end
end
