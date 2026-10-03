module LockerActions
  # Top-level orchestrator: composes visibility → filter → order → pagination.
  # Returns a Pagination; the controller assigns it directly to a single ivar.
  class Fetcher < ApplicationService
    DEFAULT_INCLUDES = [:locker, { user: :company }].freeze
    DEFAULT_ORDER    = { created_at: :desc }.freeze

    def initialize(
      user:,
      params:,
      includes: DEFAULT_INCLUDES,
      order: DEFAULT_ORDER,
      visibility: LockerActions::VisibleTo,
      filter: LockerActions::Filter,
      paginator: Pagination
    )
      @user       = user
      @params     = params
      @includes   = Array(includes)
      @order      = order
      @visibility = visibility
      @filter     = filter
      @paginator  = paginator
    end

    def call
      scope = base_scope
      scope = filtered(scope)
      scope = ordered(scope)
      paginated(scope)
    end

    def base_scope
      scope = @visibility.call(user: @user)
      @includes.any? ? scope.includes(*@includes) : scope
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
