module Lockers
  # Factory + registry for locker hardware drivers. Operators depend on
  # `Lockers::Api.for(locker:)` and never instantiate a driver directly,
  # so adding support for a new device model is a new `Api::Base` subclass
  # plus one line in the DRIVERS registry.
  module Api
    DRIVERS = {
      mock: Mock,
      http: Http
    }.freeze

    DEFAULT_DRIVER = :mock

    def self.for(locker:, driver: DEFAULT_DRIVER)
      klass = DRIVERS.fetch(driver) do
        raise ArgumentError, "Unknown locker driver #{driver.inspect}"
      end
      klass.new(locker:)
    end
  end
end
