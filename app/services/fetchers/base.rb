module Fetchers
  # Template method for a paginated, filtered, ordered list of records.
  # Subclasses provide the model, the filter class, the default includes
  # and ordering, and optionally override `base_scope` to inject
  # visibility (e.g. Lockers::Fetcher chains Lockers::VisibleTo).
  class Base < ApplicationService
    def initialize(
      params:,
      includes: self.class.default_includes,
      order: self.class.default_order,
      filter: self.class.filter_class,
      paginator: Pagination,
      model: self.class.model
    )
      @params = params
      @includes = Array(includes)
      @order = order
      @filter = filter
      @paginator = paginator
      @model = model
    end

    def call
      scope = base_scope
      scope = filtered(scope)
      scope = ordered(scope)
      paginated(scope)
    end

    class << self
      attr_accessor :model, :filter_class, :default_order, :default_includes
    end

    private

    def base_scope
      @includes.any? ? @model.includes(*@includes) : @model.all
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
