require "rails_helper"

RSpec.describe Lockers::Operators::Open do
  let(:company) { create(:company) }
  let(:locker)  { create(:locker, company: company, status: :closed) }

  describe "authorization" do
    it "raises NotAllowedError when the user cannot see the locker" do
      stranger = create(:user)

      expect {
        described_class.call(locker: locker, user: stranger, api: Lockers::Api::Mock.new(locker: locker))
      }.to raise_error(Lockers::Operators::Base::NotAllowedError)
    end

    it "does not record any action when authorization fails" do
      stranger = create(:user)

      expect {
        begin
          described_class.call(locker: locker, user: stranger, api: Lockers::Api::Mock.new(locker: locker))
        rescue Lockers::Operators::Base::NotAllowedError
          nil
        end
      }.not_to change(LockerAction, :count)
    end

    it "allows a platform owner regardless of team membership" do
      support = create(:user, :platform_owner)

      expect {
        described_class.call(locker: locker, user: support, api: Lockers::Api::Mock.new(locker: locker))
      }.not_to raise_error
    end

    it "allows a tenant user with team access" do
      user = tenant_user_with_access(locker: locker, company: company)

      expect {
        described_class.call(locker: locker, user: user, api: Lockers::Api::Mock.new(locker: locker))
      }.not_to raise_error
    end
  end

  describe "state validation" do
    it "raises InvalidStateError when the locker is already open" do
      locker.update!(status: :open)
      support = create(:user, :platform_owner)

      expect {
        described_class.call(locker: locker, user: support, api: Lockers::Api::Mock.new(locker: locker))
      }.to raise_error(Lockers::Operators::Base::InvalidStateError, /already open/)
    end
  end

  describe "happy path" do
    let(:support) { create(:user, :platform_owner) }

    it "transitions the locker to open" do
      expect {
        described_class.call(locker: locker, user: support, api: Lockers::Api::Mock.new(locker: locker))
      }.to change { locker.reload.status }.from("closed").to("open")
    end

    it "records a request action by the user and a response action by the device" do
      expect {
        described_class.call(locker: locker, user: support, api: Lockers::Api::Mock.new(locker: locker))
      }.to change(LockerAction, :count).by(2)

      actions = LockerAction.order(:id).last(2)
      expect(actions.first).to have_attributes(action: "open_request", user_id: support.id)
      expect(actions.last).to  have_attributes(action: "opened",       user_id: nil)
    end
  end

  describe "driver failure" do
    let(:support) { create(:user, :platform_owner) }
    let(:failing_api) do
      double("FailingApi").tap do |d|
        allow(d).to receive(:open).and_return(Lockers::Api::Response.failure("timeout"))
      end
    end

    it "raises DeviceError" do
      expect {
        described_class.call(locker: locker, user: support, api: failing_api)
      }.to raise_error(Lockers::Operators::Base::DeviceError, /timeout/)
    end

    it "rolls back the request action and does not change status" do
      expect {
        begin
          described_class.call(locker: locker, user: support, api: failing_api)
        rescue Lockers::Operators::Base::DeviceError
          nil
        end
      }.to not_change(LockerAction, :count)
        .and not_change { locker.reload.status }
    end
  end

  describe "row-level lock" do
    it "acquires a SELECT FOR UPDATE on the locker before mutating state" do
      support = create(:user, :platform_owner)
      allow(locker).to receive(:lock!).and_call_original

      described_class.call(locker: locker, user: support, api: Lockers::Api::Mock.new(locker: locker))

      expect(locker).to have_received(:lock!).once
    end
  end

  describe "dependency injection of the api driver" do
    it "uses the injected driver instead of the default factory" do
      support = create(:user, :platform_owner)
      spy_api = instance_double(Lockers::Api::Mock, open: Lockers::Api::Response.success)

      described_class.call(locker: locker, user: support, api: spy_api)

      expect(spy_api).to have_received(:open)
    end
  end

  private

  def tenant_user_with_access(locker:, company:)
    user = create(:user, company: company)
    team = create(:team, company: company)
    create(:teams_user, user: user, team: team, company_id: company.id)
    create(:locker_team_permission, locker: locker, team: team, company_id: company.id)
    user
  end
end
