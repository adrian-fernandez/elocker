module Lockers
  module Api
    # Mock driver: pretends the device accepted the command and succeeded.
    # Used for the demo, and as the default driver in tests when a real one
    # isn't injected.
    class Mock < Base
      def open  = Response.success
      def close = Response.success
    end
  end
end
