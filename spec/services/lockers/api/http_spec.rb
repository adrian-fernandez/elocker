require "rails_helper"

RSpec.describe Lockers::Api::Http do
  # The HTTP driver is a documented extension point: it inherits the
  # Api::Base contract but intentionally raises on #open/#close until a
  # real transport is wired. The specs lock in that behaviour so the
  # scaffold cannot silently return a success response.
  subject(:driver) { described_class.new(locker: build_stubbed(:locker)) }

  it "raises NotImplementedError for #open with the stub message" do
    expect { driver.open }.to raise_error(NotImplementedError, /not wired yet/)
  end

  it "raises NotImplementedError for #close with the stub message" do
    expect { driver.close }.to raise_error(NotImplementedError, /not wired yet/)
  end
end
