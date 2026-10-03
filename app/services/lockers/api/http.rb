module Lockers
  module Api
    # Placeholder HTTP driver. Real implementation would POST to
    # https://<device>/commands with signed credentials, retry transiently
    # failed calls, and translate the device's response into a Response.
    #
    # Left as a stub so the inheritance tree shows real alternative drivers
    # plug in here; swap the factory to point at this (or any new subclass)
    # and no caller changes.
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
