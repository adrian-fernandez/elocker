require "rails_helper"

RSpec.describe Users::Fetcher do
  describe ".call" do
    it "returns a Pagination with filtered records" do
      amazon = create(:company)
      alice  = create(:user, name: "Alice", company: amazon)
      create(:user, name: "Bob")

      result = described_class.call(params: {company_id: amazon.id})

      expect(result).to be_a(Pagination)
      expect(result.records).to contain_exactly(alice)
    end
  end
end
