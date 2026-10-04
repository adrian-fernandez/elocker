module LockerActions
  class Fetcher < Fetchers::Base
    self.model = LockerAction
    self.filter_class = LockerActions::Filter
    self.default_includes = [:locker, {user: :company}].freeze
    self.default_order = {created_at: :desc, id: :desc}.freeze

    def initialize(user:, visibility: LockerActions::VisibleTo, **kwargs)
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
