require "rails_helper"

RSpec.describe Lockers::Operators::Close do
  let(:company) { create(:company) }
  let(:locker)  { create(:locker, company:, status: :open) }
  let(:support) { create(:user, :platform_owner) }

  it "transitions an open locker to closed" do
    expect {
      described_class.call(locker:, user: support, api: Lockers::Api::Mock.new(locker:))
    }.to change { locker.reload.status }.from("open").to("closed")
  end

  it "records close_request + closed actions" do
    expect {
      described_class.call(locker:, user: support, api: Lockers::Api::Mock.new(locker:))
    }.to change(LockerAction, :count).by(2)

    actions = LockerAction.order(:id).last(2)
    expect(actions.first).to have_attributes(action: "close_request", user_id: support.id)
    expect(actions.last).to  have_attributes(action: "closed",        user_id: nil)
  end

  it "raises InvalidStateError when the locker is already closed" do
    locker.update!(status: :closed)

    expect {
      described_class.call(locker:, user: support, api: Lockers::Api::Mock.new(locker:))
    }.to raise_error(Lockers::Operators::Base::InvalidStateError, /already closed/)
  end

  it "raises NotAllowedError for a user without access" do
    stranger = create(:user)

    expect {
      described_class.call(locker:, user: stranger, api: Lockers::Api::Mock.new(locker:))
    }.to raise_error(Lockers::Operators::Base::NotAllowedError)
  end
end
