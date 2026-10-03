module Lockers
  # Top-level orchestrator used by the controllers.
  #
  # Composes the three layers of the list pipeline:
  #   authorization scope  →  filtering  →  ordering  →  pagination
  #
  # Every collaborator is injected via a keyword argument with a sensible
  # default, so tests can swap them for doubles without touching the real
  # services:
  #
  #   Lockers::Fetcher.call(
  #     user:       user,
  #     params:     params,
  #     includes:   [:company],
  #     visibility: FakeVisibleTo,
  #     filter:     FakeFilter,
  #     paginator:  FakePagination
  #   )
  #
  # Returns the Pagination instance; the controller reads `.records` for the
  # view and the Pagination object itself is passed to the shared partial.
  class Fetcher < ApplicationService
    DEFAULT_ORDER = "lockers.id ASC".freeze

    def initialize(
      user:,
      params:,
      includes: [],
      order: DEFAULT_ORDER,
      visibility: Lockers::VisibleTo,
      filter: Lockers::Filter,
      paginator: Pagination
    )
      @user = user
      @params = params
      @includes = Array(includes)
      @order = order
      @visibility = visibility
      @filter = filter
      @paginator = paginator
    end

    def call
      scope = base_scope
      scope = filtered(scope)
      scope = ordered(scope)
      paginated(scope)
    end

    def base_scope
      scope = @visibility.call(user: @user)
      scope = scope.includes(*@includes) if @includes.any?
      scope
    end

    def filtered(scope)
      @filter.call(scope:, params: @params)
    end

    def ordered(scope)
      scope.order(@order)
    end

    def paginated(scope)
      @paginator.from_params(scope, @params)
    end
  end
end
