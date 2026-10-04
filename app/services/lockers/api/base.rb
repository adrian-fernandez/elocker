module Lockers
  module Api
    # Abstract driver that talks to a locker device. Subclasses implement
    # `#open` and `#close` and must return a `Lockers::Api::Response`.
    # The driver is the only part of the stack that knows HOW to reach a
    # particular locker — HTTP, MQTT, Bluetooth, a mock. Operators and
    # controllers depend on this interface, not on any specific impl.
    class Base
      def initialize(locker:)
        @locker = locker
      end

      def open
        raise NotImplementedError, "#{self.class} must implement #open"
      end

      def close
        raise NotImplementedError, "#{self.class} must implement #close"
      end

      protected

      attr_reader :locker
    end
  end
end
