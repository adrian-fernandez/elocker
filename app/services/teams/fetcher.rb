module Teams
  class Fetcher < Fetchers::Base
    self.model = Team
    self.filter_class = Teams::Filter
    self.default_includes = [:company, :users, :lockers].freeze
    self.default_order = "teams.id ASC".freeze
  end
end
