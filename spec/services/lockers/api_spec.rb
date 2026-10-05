require "rails_helper"

RSpec.describe Lockers::Api do
  describe ".for" do
    let(:locker) { build_stubbed(:locker) }

    it "returns the default mock driver" do
      driver = described_class.for(locker:)
      expect(driver).to be_a(Lockers::Api::Mock)
    end

    it "resolves known drivers by key" do
      expect(described_class.for(locker:, driver: :mock)).to be_a(Lockers::Api::Mock)
      expect(described_class.for(locker:, driver: :http)).to be_a(Lockers::Api::Http)
    end

    it "raises on an unknown driver key" do
      expect { described_class.for(locker:, driver: :bogus) }
        .to raise_error(ArgumentError, /Unknown locker driver/)
    end
  end
end
