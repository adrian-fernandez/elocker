module Lockers
  module Api
    # Normalised response coming back from any locker driver.
    #
    #   Lockers::Api::Response.success
    #   Lockers::Api::Response.failure("Timeout contacting device")
    Response = Data.define(:ok, :message) do
      def self.success                 = new(ok: true, message: nil)
      def self.failure(message)        = new(ok: false, message:)

      def ok?    = ok
      def failed? = !ok
    end
  end
end
