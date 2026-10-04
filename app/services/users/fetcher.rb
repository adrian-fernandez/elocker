module Users
  class Fetcher < Fetchers::Base
    self.model = User
    self.filter_class = Users::Filter
    self.default_includes = [:company, :teams].freeze
    self.default_order = "users.id ASC".freeze
  end
end
