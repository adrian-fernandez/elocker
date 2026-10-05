require "rails_helper"

RSpec.describe Lockers::Operators::Base do
  # The template methods are the contract that concrete operators
  # (Open, Close, future NudgeOpen, etc.) implement. Instantiating the
  # abstract class directly and invoking the templates documents the
  # contract and keeps "subclass forgot to override" bugs loud.
  subject(:operator) do
    described_class.new(locker:, user:, api: instance_double(Lockers::Api::Mock))
  end

  let(:locker) { build_stubbed(:locker) }
  let(:user)   { build_stubbed(:user) }


  %i[initial_state_valid? request_action response_action driver_command final_status].each do |method|
    it "raises NotImplementedError when subclasses do not override ##{method}" do
      expect { operator.send(method) }.to raise_error(NotImplementedError)
    end
  end
end
