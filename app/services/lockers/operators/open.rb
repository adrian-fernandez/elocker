module Lockers
  module Operators
    class Open < Base
      private

      def initial_state_valid? = @locker.closed?
      def request_action       = :open_request
      def response_action      = :opened
      def driver_command       = :open
      def final_status         = :open
    end
  end
end
