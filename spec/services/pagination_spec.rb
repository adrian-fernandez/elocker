require "rails_helper"

RSpec.describe Pagination do
  let(:scope) { Company.all }

  describe "per_page sanitization" do
    it "defaults to #{Pagination::DEFAULT_PER_PAGE} when missing" do
      pagination = described_class.new(scope, nil, nil)
      expect(pagination.per_page).to eq(Pagination::DEFAULT_PER_PAGE)
    end

    it "defaults when non-positive" do
      expect(described_class.new(scope, nil, "0").per_page).to eq(Pagination::DEFAULT_PER_PAGE)
      expect(described_class.new(scope, nil, "-5").per_page).to eq(Pagination::DEFAULT_PER_PAGE)
    end

    it "caps at MAX_PER_PAGE" do
      expect(described_class.new(scope, nil, "999").per_page).to eq(Pagination::MAX_PER_PAGE)
    end

    it "accepts valid values" do
      expect(described_class.new(scope, nil, "2").per_page).to eq(2)
      expect(described_class.new(scope, nil, "50").per_page).to eq(50)
    end
  end

  describe "page sanitization" do
    before { create_list(:company, 5) }

    it "defaults to 1 when missing" do
      expect(described_class.new(scope, nil, 2).page).to eq(1)
    end

    it "clamps at upper bound (page_count)" do
      expect(described_class.new(scope, 999, 2).page).to eq(3) # 5 records, 2 per_page
    end

    it "defaults when non-positive" do
      expect(described_class.new(scope, "0", 2).page).to eq(1)
      expect(described_class.new(scope, "-1", 2).page).to eq(1)
    end
  end

  describe "offset + range" do
    before { create_list(:company, 5) }

    it "returns 1..n on first page" do
      p = described_class.new(scope, 1, 2)
      expect(p.offset).to eq(0)
      expect(p.range_from).to eq(1)
      expect(p.range_to).to eq(2)
    end

    it "handles trailing partial page" do
      p = described_class.new(scope, 3, 2)
      expect(p.offset).to eq(4)
      expect(p.range_from).to eq(5)
      expect(p.range_to).to eq(5)
    end

    it "range_from is zero when total is zero" do
      p = described_class.new(Company.where(id: 0), 1, 10)
      expect(p.range_from).to eq(0)
    end
  end

  describe "first_page? / last_page?" do
    before { create_list(:company, 3) }

    it "flags boundaries correctly" do
      expect(described_class.new(scope, 1, 2)).to be_first_page
      expect(described_class.new(scope, 2, 2)).to be_last_page
    end
  end

  describe "records" do
    before { create_list(:company, 5) }

    it "slices the scope by offset/limit" do
      records = described_class.new(scope.order(:id), 2, 2).records
      expect(records.length).to eq(2)
    end
  end

  describe "enumerable behaviour" do
    before { create_list(:company, 3) }

    let(:pagination) { described_class.new(scope.order(:id), 1, 10) }

    it "iterates records via each" do
      yielded = []
      pagination.each { |c| yielded << c }

      expect(yielded.length).to eq(3)
      expect(yielded.first).to be_a(Company)
    end

    it "supports map, any?, empty?, length via Enumerable" do
      expect(pagination.map(&:id).length).to eq(3)
      expect(pagination.any?).to be true
      expect(pagination).not_to be_empty
      expect(pagination.length).to eq(3)
      expect(pagination.size).to eq(3)
    end

    it "any? is false when the page has no records" do
      empty = described_class.new(Company.where(id: 0), 1, 10)
      expect(empty.any?).to be false
      expect(empty).to be_empty
    end
  end
end
