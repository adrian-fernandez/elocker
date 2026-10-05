require "rails_helper"

RSpec.describe Lockers::Filter do
  let(:scope) { Locker.all }

  describe "#by_name" do
    before do
      create(:locker, name: "Amazon Locker A1")
      create(:locker, name: "DPD Locker D1")
    end

    it "filters by ILIKE %name%" do
      filter = described_class.new(scope:, params: {name: "amazon"})
      expect(filter.by_name(scope).map(&:name)).to all(include("Amazon"))
    end

    it "is a no-op on blank input" do
      filter = described_class.new(scope:, params: {})
      expect(filter.by_name(scope).count).to eq(2)
    end

    it "treats user-supplied `_` as a literal, not a single-char wildcard" do
      # Without escaping, ILIKE '%Amazon_%' matches BOTH "Amazon_Locker"
      # (literal _) AND "AmazonXLocker" (_ as any single char). Escaping
      # the input locks the match to the literal underscore row.
      create(:locker, name: "Amazon_Locker")
      create(:locker, name: "AmazonXLocker")

      filter = described_class.new(scope:, params: {name: "Amazon_"})

      expect(filter.by_name(scope).map(&:name)).to contain_exactly("Amazon_Locker")
    end

    it "treats user-supplied `%` as a literal, not a multi-char wildcard" do
      # Without escaping, "Amazon%" would match "AmazonExtra" via wildcard;
      # escaping forces an exact `Amazon%` substring match.
      create(:locker, name: "Amazon%Promo")
      create(:locker, name: "AmazonExtra")

      filter = described_class.new(scope:, params: {name: "Amazon%"})

      expect(filter.by_name(scope).map(&:name)).to contain_exactly("Amazon%Promo")
    end
  end

  describe "#by_device_id" do
    before do
      create(:locker, physical_device: create(:physical_device, device_id: "AMZ-001"))
      create(:locker, physical_device: create(:physical_device, device_id: "DPD-001"))
    end

    it "filters by ILIKE %device_id%" do
      filter = described_class.new(scope:, params: {device_id: "amz"})
      expect(filter.by_device_id(scope).map(&:device_id)).to eq(["AMZ-001"])
    end
  end

  describe "#by_company" do
    it "filters to the given company" do
      amazon = create(:company)
      dpd    = create(:company)
      a_locker = create(:locker, company: amazon)
      create(:locker, company: dpd)

      filter = described_class.new(scope:, params: {company_id: amazon.id})
      expect(filter.by_company(scope)).to contain_exactly(a_locker)
    end
  end

  describe "#by_status" do
    before do
      create(:locker, status: :open)
      create(:locker, status: :closed)
    end

    it "accepts 'open'" do
      filter = described_class.new(scope:, params: {status: "open"})
      expect(filter.by_status(scope).map(&:status)).to eq(["open"])
    end

    it "accepts 'closed'" do
      filter = described_class.new(scope:, params: {status: "closed"})
      expect(filter.by_status(scope).map(&:status)).to eq(["closed"])
    end

    it "ignores invalid values" do
      filter = described_class.new(scope:, params: {status: "bogus"})
      expect(filter.by_status(scope).count).to eq(2)
    end
  end

  describe "#by_team" do
    it "filters lockers to a given team's permissions" do
      company = create(:company)
      team    = create(:team, company:)
      locker  = create(:locker, company:)
      create(:locker_team_permission, locker:, team:, company_id: company.id)
      create(:locker, company:) # unrelated

      filter = described_class.new(scope:, params: {team_id: team.id})
      expect(filter.by_team(scope)).to contain_exactly(locker)
    end
  end

  describe "#call" do
    it "composes filters and dedupes with distinct" do
      company = create(:company)
      team    = create(:team, company:)
      locker  = create(:locker, company:, name: "A1", status: :open)
      create(:locker_team_permission, locker:, team:, company_id: company.id)
      create(:locker, company:, name: "A2", status: :closed)

      filter = described_class.new(scope:, params: {
        name: "A", company_id: company.id, status: "open", team_id: team.id
      })

      expect(filter.call).to contain_exactly(locker)
    end
  end
end
