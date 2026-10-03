require "rails_helper"

RSpec.describe Lockers::Api::Mock do
  let(:locker) { build_stubbed(:locker) }
  subject(:driver) { described_class.new(locker: locker) }

  describe "#open" do
    it "returns a successful response" do
      expect(driver.open).to be_ok
    end
  end

  describe "#close" do
    it "returns a successful response" do
      expect(driver.close).to be_ok
    end
  end
end
