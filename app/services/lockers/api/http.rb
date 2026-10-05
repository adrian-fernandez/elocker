module Lockers
  module Api
    # Placeholder HTTP driver -- left as a stub to document the extension
    # point. A real impl would POST signed commands to the device, retry
    # transient failures, and translate the response into Api::Response.
    class Http < Base
      def open
        raise NotImplementedError, "Http driver not wired yet"
      end

      def close
        raise NotImplementedError, "Http driver not wired yet"
      end
    end
  end
end
