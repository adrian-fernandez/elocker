module LockerActions
  # Uses keyset (cursor) pagination because activity rows are append-only
  # and ordered DESC; no need for COUNT(*) to render the pager.
  class Fetcher < Fetchers::Base
    self.model = LockerAction
    self.filter_class = LockerActions::Filter
    self.default_includes = [:locker, {user: :company}].freeze
    self.default_order = {created_at: :desc, id: :desc}.freeze

    def initialize(user:, visibility: LockerActions::VisibleTo, paginator: CursorPagination, **kwargs)
      super(**kwargs.merge(paginator:))
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
