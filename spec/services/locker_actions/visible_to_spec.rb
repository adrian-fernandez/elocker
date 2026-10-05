require "rails_helper"

RSpec.describe LockerActions::VisibleTo do
  describe ".call" do
    let(:amazon)        { create(:company) }
    let(:other_company) { create(:company) }
    let(:amazon_locker) { create(:locker, company: amazon) }
    let(:other_locker)  { create(:locker, company: other_company) }

    context "when the user is a platform owner" do
      let(:platform_user) { create(:user, :platform_owner) }

      it "returns every action on the platform" do
        on_amazon = create(:locker_action, locker: amazon_locker, company_id: amazon.id)
        on_other  = create(:locker_action, locker: other_locker,  company_id: other_company.id)

        result = described_class.call(user: platform_user)

        expect(result).to contain_exactly(on_amazon, on_other)
      end
    end

    context "when the user is a tenant" do
      let(:tenant_user) do
        user = create(:user, company: amazon)
        team = create(:team, company: amazon)
        create(:teams_user, user:, team:, company_id: amazon.id)
        create(:locker_team_permission, locker: amazon_locker, team:, company_id: amazon.id)
        user
      end

      it "returns only actions on lockers the user can see" do
        in_scope = create(:locker_action, locker: amazon_locker, company_id: amazon.id)
        _out     = create(:locker_action, locker: other_locker,  company_id: other_company.id)

        unrelated_amazon_locker = create(:locker, company: amazon)
        _unrelated = create(:locker_action, locker: unrelated_amazon_locker, company_id: amazon.id)

        result = described_class.call(user: tenant_user)

        expect(result).to contain_exactly(in_scope)
      end
    end
  end
end
