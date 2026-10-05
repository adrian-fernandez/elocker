require "rails_helper"

RSpec.describe LockerOperations do
  # The concern mandates that every including controller implement
  # `locker_route(locker_or_id)` so redirects point at the correct
  # URL namespace (admin vs. client). Including the concern without
  # providing an override must fail loudly, not silently redirect to
  # the wrong path.
  describe "default #locker_route" do
    let(:dummy_class) do
      Class.new(ActionController::Base) do
        include LockerOperations
      end
    end

    it "raises NotImplementedError until the including controller overrides it" do
      expect { dummy_class.new.send(:locker_route, 1) }
        .to raise_error(NotImplementedError, /must implement/)
    end
  end
end
