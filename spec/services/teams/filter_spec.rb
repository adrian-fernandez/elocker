require "rails_helper"

RSpec.describe Teams::Filter do
  let(:scope) { Team.all }

  describe "#by_name" do
    it "ILIKEs the team name" do
      warehouse = create(:team, name: "Warehouse")
      create(:team, name: "Drivers")

      filter = described_class.new(scope: scope, params: { name: "ware" })
      expect(filter.by_name(scope)).to contain_exactly(warehouse)
    end
  end

  describe "#by_company" do
    it "filters to a company" do
      amazon = create(:company)
      amazon_team = create(:team, company: amazon)
      create(:team) # another company

      filter = described_class.new(scope: scope, params: { company_id: amazon.id })
      expect(filter.by_company(scope)).to contain_exactly(amazon_team)
    end
  end

  describe "#by_member_name" do
    it "filters teams that have a user whose name matches" do
      company   = create(:company)
      warehouse = create(:team, company: company)
      alice     = create(:user, name: "Alice Johnson", company: company)
      create(:teams_user, user: alice, team: warehouse, company_id: company.id)

      lonely_team = create(:team, company: company)

      filter = described_class.new(scope: scope, params: { members: "alice" })
      result = filter.by_member_name(scope)

      expect(result).to include(warehouse)
      expect(result).not_to include(lonely_team)
    end
  end

  describe "#by_locker_name" do
    it "filters teams that have a locker whose name matches" do
      company = create(:company)
      team    = create(:team, company: company)
      locker  = create(:locker, name: "A1", company: company)
      create(:locker_team_permission, locker: locker, team: team, company_id: company.id)

      lonely_team = create(:team, company: company)

      filter = described_class.new(scope: scope, params: { lockers: "A1" })
      result = filter.by_locker_name(scope)

      expect(result).to include(team)
      expect(result).not_to include(lonely_team)
    end
  end

  describe "#call" do
    it "composes all filters and dedupes" do
      company = create(:company)
      team    = create(:team, name: "Warehouse", company: company)
      alice   = create(:user, name: "Alice", company: company)
      locker  = create(:locker, name: "A1", company: company)
      create(:teams_user, user: alice, team: team, company_id: company.id)
      create(:locker_team_permission, locker: locker, team: team, company_id: company.id)

      create(:team, name: "Operations", company: company) # noise

      result = described_class.new(scope: scope, params: {
        name: "ware", company_id: company.id, members: "alice", lockers: "A1"
      }).call

      expect(result).to contain_exactly(team)
    end
  end
end
