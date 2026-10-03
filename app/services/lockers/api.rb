module Lockers
  # Factory + registry for locker drivers.
  #
  # The operator services depend on `Lockers::Api.for(locker:)` and never
  # instantiate a driver directly. That keeps the dispatch logic ("what kind
  # of locker is this?") in exactly one place; adding support for a new
  # device model is a new `Api::Base` subclass plus one line here.
  module Api
    DRIVERS = {
      mock: Mock,
      http: Http
    }.freeze

    DEFAULT_DRIVER = :mock

    # Returns a driver instance for the given locker. Right now every locker
    # is mocked; in production this would dispatch on `locker.model`,
    # `locker.firmware`, or similar.
    def self.for(locker:, driver: DEFAULT_DRIVER)
      klass = DRIVERS.fetch(driver) do
        raise ArgumentError, "Unknown locker driver #{driver.inspect}"
      end
      klass.new(locker: locker)
    end
  end
end
