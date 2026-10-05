require "rails_helper"

RSpec.describe LockerAction, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:locker) }
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to belong_to(:company).optional }
  end

  describe "company_matches_locker validation" do
    it "accepts a nil company when the locker is unassigned" do
      locker = create(:locker, :unassigned)
      action = build(:locker_action, locker:, company_id: nil, user: build(:user, :platform_owner))

      expect(action).to be_valid
    end

    it "rejects a mismatched company" do
      locker = create(:locker)
      action = build(:locker_action, locker:, company_id: create(:company).id)

      expect(action).not_to be_valid
      expect(action.errors[:company_id]).to be_present
    end
  end

  describe "action enum" do
    it {
      is_expected.to define_enum_for(:action).with_values(
        open_request: 0,
        close_request: 1,
        opened: 2,
        closed: 3
      )
    }
  end

  describe "user is optional for device-generated responses" do
    it "accepts nil user on :opened" do
      locker = create(:locker)
      action = build(:locker_action, :opened, locker:, user: nil)
      expect(action).to be_valid
    end
  end

  describe "user_matches_action_type validation" do
    it "requires a user for request actions" do
      locker = create(:locker)
      action = build(:locker_action, :open_request, locker:, user: nil)

      expect(action).not_to be_valid
      expect(action.errors[:user].first).to include("required for open_request")
    end

    it "forbids a user on device-generated responses" do
      locker = create(:locker)
      action = build(:locker_action, :closed, locker:, user: build(:user, company: locker.company))

      expect(action).not_to be_valid
      expect(action.errors[:user].first).to include("must be nil for closed")
    end
  end

  describe "composite tenant integrity" do
    it "requires the action's company_id to match its locker's company_id" do
      locker = create(:locker)
      user   = create(:user)

      insert_sql = <<~SQL
        INSERT INTO locker_actions
          (locker_id, user_id, company_id, action, created_at, updated_at)
        VALUES
          (#{locker.id}, #{user.id}, #{create(:company).id}, 0, NOW(), NOW())
      SQL

      expect { ActiveRecord::Base.connection.execute(insert_sql) }
        .to raise_error(ActiveRecord::StatementInvalid)
    end

    it "allows a platform-owner user to operate lockers in another company" do
      amazon         = create(:company, name: "Amazon")
      amazon_locker  = create(:locker, company: amazon)
      platform_user  = create(:user, :platform_owner)

      action = described_class.new(
        locker: amazon_locker,
        user: platform_user,
        company_id: amazon.id,
        action: :open_request
      )

      expect(action).to be_valid
      expect { action.save! }.not_to raise_error
    end
  end
end
