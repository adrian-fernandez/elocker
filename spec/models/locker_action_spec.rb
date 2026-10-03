require "rails_helper"

RSpec.describe LockerAction, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:locker) }
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to belong_to(:company) }
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
      action = build(:locker_action, :opened, locker: locker, user: nil)
      expect(action).to be_valid
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

      action = LockerAction.new(
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
