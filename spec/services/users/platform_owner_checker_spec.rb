require "rails_helper"

RSpec.describe Users::PlatformOwnerChecker do
  describe ".call" do
    it "is true for a user in the platform owner company" do
      user = create(:user, :platform_owner)
      expect(described_class.call(user:)).to be true
    end

    it "is false for a tenant user" do
      user = create(:user)
      expect(described_class.call(user:)).to be false
    end

    it "is false when user is nil" do
      expect(described_class.call(user: nil)).to be false
    end

    it "is false when the user has no company" do
      user = build_stubbed(:user).tap { |u| allow(u).to receive(:company).and_return(nil) }
      expect(described_class.call(user:)).to be false
    end
  end
end
