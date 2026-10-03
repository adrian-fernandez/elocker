require "rails_helper"

RSpec.describe Users::Filter do
  let(:scope) { User.all }

  describe "#by_name" do
    it "filters by ILIKE %name%" do
      alice = create(:user, name: "Alice Johnson")
      create(:user, name: "Bob Smith")

      filter = described_class.new(scope: scope, params: { name: "alice" })
      expect(filter.by_name(scope)).to contain_exactly(alice)
    end
  end

  describe "#by_company" do
    it "filters to the given company" do
      amazon = create(:company)
      alice  = create(:user, company: amazon)
      create(:user)

      filter = described_class.new(scope: scope, params: { company_id: amazon.id })
      expect(filter.by_company(scope)).to contain_exactly(alice)
    end
  end

  describe "#by_team" do
    it "filters users to those in the given team" do
      company = create(:company)
      team    = create(:team, company: company)
      alice   = create(:user, company: company)
      create(:teams_user, user: alice, team: team, company_id: company.id)
      create(:user, company: company)

      filter = described_class.new(scope: scope, params: { team_id: team.id })
      expect(filter.by_team(scope)).to contain_exactly(alice)
    end
  end

  describe "#call" do
    it "composes all filters" do
      amazon = create(:company)
      team   = create(:team, company: amazon)
      alice  = create(:user, name: "Alice Johnson", company: amazon)
      create(:teams_user, user: alice, team: team, company_id: amazon.id)
      create(:user, name: "Alice Other", company: amazon)

      filter = described_class.new(scope: scope, params: {
        name: "Alice", company_id: amazon.id, team_id: team.id
      })

      expect(filter.call).to contain_exactly(alice)
    end
  end
end
