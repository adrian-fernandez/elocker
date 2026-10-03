module Companies
  # Top-level orchestrator: composes base scope → filter → order → pagination.
  # See `Lockers::Fetcher` for the architectural pattern used across entities.
  class Fetcher < ApplicationService
    DEFAULT_INCLUDES = [:users, :teams, :lockers].freeze
    DEFAULT_ORDER = { platform_owner: :desc, name: :asc }.freeze

    def initialize(
      params:,
      includes: DEFAULT_INCLUDES,
      order: DEFAULT_ORDER,
      model: Company,
      filter: Companies::Filter,
      paginator: Pagination
    )
      @params = params
      @includes = Array(includes)
      @order = order
      @model = model
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
      @includes.any? ? @model.includes(*@includes) : @model.all
    end

    def filtered(scope)
      @filter.call(scope: scope, params: @params)
    end

    def ordered(scope)
      scope.order(@order)
    end

    def paginated(scope)
      @paginator.from_params(scope, @params)
    end
  end
end
