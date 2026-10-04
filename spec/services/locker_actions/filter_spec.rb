require "rails_helper"

RSpec.describe LockerActions::Filter do
  let(:scope) { LockerAction.all }

  describe "#by_company" do
    it "filters to the given company" do
      amazon = create(:company)
      dpd    = create(:company)
      a      = create(:locker_action, locker: create(:locker, company: amazon), company_id: amazon.id)
      _b     = create(:locker_action, locker: create(:locker, company: dpd),    company_id: dpd.id)

      result = described_class.new(scope: scope, params: {company_id: amazon.id}).by_company(scope)
      expect(result).to contain_exactly(a)
    end
  end

  describe "#by_locker" do
    it "filters to actions on a specific locker" do
      locker = create(:locker)
      a = create(:locker_action, locker: locker, company_id: locker.company_id)
      _b = create(:locker_action)

      result = described_class.new(scope: scope, params: {locker_id: locker.id}).by_locker(scope)
      expect(result).to contain_exactly(a)
    end
  end

  describe "#by_user" do
    it "filters to actions by a specific user" do
      user = create(:user)
      a = create(:locker_action, user: user, locker: create(:locker, company: user.company), company_id: user.company_id)
      _b = create(:locker_action)

      result = described_class.new(scope: scope, params: {user_id: user.id}).by_user(scope)
      expect(result).to contain_exactly(a)
    end
  end

  describe "#by_team" do
    it "filters to actions whose actor belongs to the given team" do
      company = create(:company)
      locker  = create(:locker, company: company)
      team    = create(:team, company: company)
      member  = create(:user, company: company)
      create(:teams_user, user: member, team: team, company_id: company.id)

      in_team    = create(:locker_action, user: member,         locker: locker, company_id: company.id)
      _outsider  = create(:locker_action, user: create(:user, company: company), locker: locker, company_id: company.id)
      _device    = create(:locker_action, :opened, locker: locker, company_id: company.id)

      result = described_class.new(scope: scope, params: {team_id: team.id}).by_team(scope)
      expect(result).to contain_exactly(in_team)
    end
  end

  describe "#by_action" do
    it "filters to a specific action enum value" do
      locker = create(:locker)
      opened = create(:locker_action, :opened, locker: locker, company_id: locker.company_id)
      _req   = create(:locker_action, :open_request, locker: locker, company_id: locker.company_id)

      result = described_class.new(scope: scope, params: {action_type: "opened"}).by_action(scope)
      expect(result).to contain_exactly(opened)
    end

    it "ignores unknown values" do
      locker = create(:locker)
      a = create(:locker_action, locker: locker, company_id: locker.company_id)

      result = described_class.new(scope: scope, params: {action_type: "bogus"}).by_action(scope)
      expect(result).to include(a)
    end
  end

  describe "#by_actor_type" do
    let!(:platform_user) { create(:user, :platform_owner) }
    let!(:tenant_user)   { create(:user) }
    let(:locker)         { create(:locker, company: tenant_user.company) }

    let!(:by_platform) { create(:locker_action, user: platform_user, locker: locker, company_id: locker.company_id) }
    let!(:by_tenant)   { create(:locker_action, user: tenant_user,   locker: locker, company_id: locker.company_id) }
    let!(:by_device)   { create(:locker_action, :opened,              locker: locker, company_id: locker.company_id) }

    it "narrows to platform-owner actions" do
      result = described_class.new(scope: scope, params: {actor_type: "platform"}).by_actor_type(scope)
      expect(result).to contain_exactly(by_platform)
    end

    it "narrows to tenant-employee actions" do
      result = described_class.new(scope: scope, params: {actor_type: "tenant"}).by_actor_type(scope)
      expect(result).to contain_exactly(by_tenant)
    end

    it "narrows to device-reported actions" do
      result = described_class.new(scope: scope, params: {actor_type: "device"}).by_actor_type(scope)
      expect(result).to contain_exactly(by_device)
    end
  end

  describe "#by_date_from and #by_date_to" do
    let(:locker) { create(:locker) }
    let!(:old) { create(:locker_action, locker: locker, company_id: locker.company_id, created_at: 10.days.ago) }
    let!(:recent) { create(:locker_action, locker: locker, company_id: locker.company_id, created_at: 1.day.ago) }

    it "by_date_from filters created_at >= from (beginning of day)" do
      from = 2.days.ago.to_date.to_s
      result = described_class.new(scope: scope, params: {from: from}).by_date_from(scope)
      expect(result).to contain_exactly(recent)
    end

    it "by_date_to filters created_at <= to (end of day)" do
      to = 5.days.ago.to_date.to_s
      result = described_class.new(scope: scope, params: {to: to}).by_date_to(scope)
      expect(result).to contain_exactly(old)
    end

    it "ignores unparseable dates" do
      result = described_class.new(scope: scope, params: {from: "not-a-date"}).by_date_from(scope)
      expect(result.count).to eq(2)
    end
  end

  describe "#call (composition)" do
    it "composes filters and dedupes with distinct" do
      amazon  = create(:company)
      locker  = create(:locker, company: amazon)
      user    = create(:user, company: amazon)
      team    = create(:team, company: amazon)
      create(:teams_user, user: user, team: team, company_id: amazon.id)

      match = create(:locker_action, :open_request, user: user, locker: locker, company_id: amazon.id, created_at: 1.hour.ago)
      _other_user = create(:locker_action, :open_request, locker: locker, company_id: amazon.id)
      _other_action = create(:locker_action, :opened, locker: locker, company_id: amazon.id)

      result = described_class.new(scope: scope, params: {
        company_id: amazon.id,
        locker_id: locker.id,
        user_id: user.id,
        team_id: team.id,
        action_type: "open_request",
        actor_type: "tenant",
        from: 2.hours.ago.to_date.to_s
      }).call

      expect(result).to contain_exactly(match)
    end
  end
end
