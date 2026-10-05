require "rails_helper"

RSpec.describe Lockers::VisibleTo do
  describe ".call" do
    context "when the user is a platform owner" do
      let(:platform_user) { create(:user, :platform_owner) }
      let!(:amazon_locker) { create(:locker) }
      let!(:dpd_locker)    { create(:locker) }

      it "returns every locker on the platform" do
        result = described_class.call(user: platform_user)
        expect(result).to contain_exactly(amazon_locker, dpd_locker)
      end
    end

    context "when the user is a tenant" do
      let(:company)   { create(:company) }
      let(:team)      { create(:team, company:) }
      let(:user)      { create(:user, company:) }
      let!(:in_scope) { create(:locker, company:) }

      before do
        create(:teams_user, user:, team:, company_id: company.id)
        create(:locker_team_permission, locker: in_scope, team:, company_id: company.id)
      end

      it "returns lockers accessible via their team membership" do
        result = described_class.call(user:)
        expect(result).to contain_exactly(in_scope)
      end

      it "excludes lockers whose teams the user does not belong to" do
        other_team   = create(:team, company:)
        other_locker = create(:locker, company:)
        create(:locker_team_permission, locker: other_locker, team: other_team, company_id: company.id)

        result = described_class.call(user:)
        expect(result).not_to include(other_locker)
      end

      it "excludes lockers from other companies even if a stray permission existed" do
        other_company_locker = create(:locker, company: create(:company))

        result = described_class.call(user:)
        expect(result).not_to include(other_company_locker)
      end
    end
  end
end
