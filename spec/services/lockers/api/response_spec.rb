require "rails_helper"

RSpec.describe Lockers::Api::Response do
  describe ".success" do
    it "is ok and carries no message" do
      resp = described_class.success
      expect(resp).to be_ok
      expect(resp.failed?).to be false
      expect(resp.message).to be_nil
    end
  end

  describe ".failure" do
    it "is not ok and carries the message" do
      resp = described_class.failure("boom")
      expect(resp.failed?).to be true
      expect(resp.ok?).to be false
      expect(resp.message).to eq("boom")
    end
  end
end
