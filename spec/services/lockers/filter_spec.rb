require "rails_helper"

RSpec.describe Lockers::Filter do
  let(:scope) { Locker.all }

  describe "#by_name" do
    before do
      create(:locker, name: "Amazon Locker A1")
      create(:locker, name: "DPD Locker D1")
    end

    it "filters by ILIKE %name%" do
      filter = described_class.new(scope: scope, params: { name: "amazon" })
      expect(filter.by_name(scope).map(&:name)).to all(include("Amazon"))
    end

    it "is a no-op on blank input" do
      filter = described_class.new(scope: scope, params: {})
      expect(filter.by_name(scope).count).to eq(2)
    end

    it "escapes LIKE wildcards from user input" do
      create(:locker, name: "Amazon_Locker")
      filter = described_class.new(scope: scope, params: { name: "Amazon_" })
      expect(filter.by_name(scope).map(&:name)).to eq(["Amazon_Locker"])
    end
  end

  describe "#by_device_id" do
    before do
      create(:locker, device_id: "AMZ-001")
      create(:locker, device_id: "DPD-001")
    end

    it "filters by ILIKE %device_id%" do
      filter = described_class.new(scope: scope, params: { device_id: "amz" })
      expect(filter.by_device_id(scope).map(&:device_id)).to eq(["AMZ-001"])
    end
  end

  describe "#by_company" do
    it "filters to the given company" do
      amazon = create(:company)
      dpd    = create(:company)
      a_locker = create(:locker, company: amazon)
      create(:locker, company: dpd)

      filter = described_class.new(scope: scope, params: { company_id: amazon.id })
      expect(filter.by_company(scope)).to contain_exactly(a_locker)
    end
  end

  describe "#by_status" do
    before do
      create(:locker, status: :open)
      create(:locker, status: :closed)
    end

    it "accepts 'open'" do
      filter = described_class.new(scope: scope, params: { status: "open" })
      expect(filter.by_status(scope).map(&:status)).to eq(["open"])
    end

    it "accepts 'closed'" do
      filter = described_class.new(scope: scope, params: { status: "closed" })
      expect(filter.by_status(scope).map(&:status)).to eq(["closed"])
    end

    it "ignores invalid values" do
      filter = described_class.new(scope: scope, params: { status: "bogus" })
      expect(filter.by_status(scope).count).to eq(2)
    end
  end

  describe "#by_team" do
    it "filters lockers to a given team's permissions" do
      company = create(:company)
      team    = create(:team, company: company)
      locker  = create(:locker, company: company)
      create(:locker_team_permission, locker: locker, team: team, company_id: company.id)
      create(:locker, company: company) # unrelated

      filter = described_class.new(scope: scope, params: { team_id: team.id })
      expect(filter.by_team(scope)).to contain_exactly(locker)
    end
  end

  describe "#call" do
    it "composes filters and dedupes with distinct" do
      company = create(:company)
      team    = create(:team, company: company)
      locker  = create(:locker, company: company, name: "A1", status: :open)
      create(:locker_team_permission, locker: locker, team: team, company_id: company.id)
      create(:locker, company: company, name: "A2", status: :closed)

      filter = described_class.new(scope: scope, params: {
        name: "A", company_id: company.id, status: "open", team_id: team.id
      })

      expect(filter.call).to contain_exactly(locker)
    end
  end
end
