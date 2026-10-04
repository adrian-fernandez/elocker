require "rails_helper"

RSpec.describe Companies::Fetcher do
  describe ".call" do
    it "returns a Pagination with filtered + ordered records" do
      elocker = create(:company, :platform)
      _amazon = create(:company, name: "Amazon")
      _dpd    = create(:company, name: "DPD")

      result = described_class.call(params: {type: "platform"})

      expect(result).to be_a(Pagination)
      expect(result.records).to contain_exactly(elocker)
    end

    it "orders platform owners first, then alphabetically" do
      amazon  = create(:company, name: "Amazon")
      elocker = create(:company, :platform)
      dpd     = create(:company, name: "DPD")

      result = described_class.call(params: {})
      expect(result.records.to_a).to eq([elocker, amazon, dpd])
    end

    it "paginates" do
      7.times { |i| create(:company, name: "Co #{i}") }

      result = described_class.call(params: {per_page: 3, page: 2})
      expect(result.records.size).to eq(3)
    end
  end
end
