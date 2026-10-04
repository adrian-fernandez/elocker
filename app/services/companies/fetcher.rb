module Companies
  # No eager-loaded includes: the admin dashboard reads counter_cache columns
  # directly on `companies` (users_count / teams_count / lockers_count).
  class Fetcher < Fetchers::Base
    self.model = Company
    self.filter_class = Companies::Filter
    self.default_includes = [].freeze
    self.default_order = {platform_owner: :desc, name: :asc}.freeze
  end
end
