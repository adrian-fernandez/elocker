module Lockers
  class Fetcher < Fetchers::Base
    self.model = Locker
    self.filter_class = Lockers::Filter
    self.default_includes = [].freeze
    self.default_order = "lockers.id ASC".freeze

    def initialize(user:, visibility: Lockers::VisibleTo, **kwargs)
      super(**kwargs)
      @user = user
      @visibility = visibility
    end

    private

    def base_scope
      scope = @visibility.call(user: @user)
      @includes.any? ? scope.includes(*@includes) : scope
    end
  end
end
