require "rails_helper"

RSpec.describe Companies::Filter do
  let(:scope) { Company.all }

  describe "#by_name" do
    it "filters by ILIKE" do
      amazon = create(:company, name: "Amazon")
      create(:company, name: "DPD")

      filter = described_class.new(scope:, params: {name: "amaz"})
      expect(filter.by_name(scope)).to contain_exactly(amazon)
    end
  end

  describe "#by_type" do
    let!(:elocker) { create(:company, :platform) }
    let!(:amazon)  { create(:company) }

    it "returns platform companies on 'platform'" do
      filter = described_class.new(scope:, params: {type: "platform"})
      expect(filter.by_type(scope)).to contain_exactly(elocker)
    end

    it "returns tenants on 'tenant'" do
      filter = described_class.new(scope:, params: {type: "tenant"})
      expect(filter.by_type(scope)).to contain_exactly(amazon)
    end

    it "ignores unknown values" do
      filter = described_class.new(scope:, params: {type: "bogus"})
      expect(filter.by_type(scope).count).to eq(2)
    end
  end
end
