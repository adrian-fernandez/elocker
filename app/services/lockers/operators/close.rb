module Lockers
  module Operators
    class Close < Base
      private

      def initial_state_valid? = @locker.open?
      def request_action       = :close_request
      def response_action      = :closed
      def driver_command       = :close
      def final_status         = :closed
    end
  end
end
