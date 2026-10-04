module Lockers
  module Api
    # Mock driver: pretends the device accepted the command and succeeded.
    # Default in dev/demo and in tests that don't inject their own.
    class Mock < Base
      def open = Response.success
      def close = Response.success
    end
  end
end
