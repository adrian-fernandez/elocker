module Lockers
  module Api
    Response = Data.define(:ok, :message) do
      def self.success = new(ok: true, message: nil)
      def self.failure(message) = new(ok: false, message:)

      def ok? = ok
      def failed? = !ok
    end
  end
end
