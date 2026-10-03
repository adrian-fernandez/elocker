require "rails_helper"

RSpec.describe Lockers::Api::Base do
  let(:locker) { build_stubbed(:locker) }
  subject(:driver) { described_class.new(locker: locker) }

  it "raises NotImplementedError for #open" do
    expect { driver.open }.to raise_error(NotImplementedError, /#open/)
  end

  it "raises NotImplementedError for #close" do
    expect { driver.close }.to raise_error(NotImplementedError, /#close/)
  end
end
