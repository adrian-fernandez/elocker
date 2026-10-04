require "capybara/rspec"

# No headless browser available in the dev container; the rack_test driver
# runs Capybara in-process, which is fine for Turbo Drive flows (no JS).
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end
end
