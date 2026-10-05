require "spec_helper"
# The Docker dev container boots with RAILS_ENV=development; hard-set it
# here before Rails loads so the suite always talks to the test DB.
ENV["RAILS_ENV"] = "test"
require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "prosopite"
require "capybara/rails"
Rails.root.glob("spec/support/**/*.rb").sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # Our own around-each handles isolation across every spec type, including
  # spec/services (which rspec-rails does not infer as a Rails spec).
  config.use_transactional_fixtures = false

  config.include FactoryBot::Syntax::Methods
  config.infer_spec_type_from_file_location!

  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end

  # Prosopite flags N+1s on request/system specs that render views. Models
  # and services opt out — many of them intentionally measure DB queries
  # without eager-loading to assert behaviour.
  config.around(:each, type: :request) do |example|
    Prosopite.scan
    example.run
  ensure
    Prosopite.finish
  end

  config.around(:each, type: :system) do |example|
    Prosopite.scan
    example.run
  ensure
    Prosopite.finish
  end

  config.filter_rails_from_backtrace!
end

Prosopite.rails_logger = true
Prosopite.raise = true
# Allow queries from within the fixtures/factories setup. Only scan the
# `example.run` call itself.

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec::Matchers.define_negated_matcher :not_change, :change
