module Lockers
  # Applies query-string filters to an existing Locker relation.
  #
  # Each filter is its own public method: it receives a scope and returns a
  # scope, idempotent on blank input. `call` composes them in explicit order.
  # Add a new filter by writing a `by_<thing>` method and adding one line to
  # `call`; delete one by removing the line. Each method is testable in
  # isolation without touching the others.
  class Filter < ApplicationService
    def initialize(scope:, params:, model: Locker)
      @scope = scope
      @params = params
      @model = model
    end

    def call
      scope = @scope
      scope = by_name(scope)
      scope = by_device_id(scope)
      scope = by_company(scope)
      scope = by_status(scope)
      scope = by_team(scope)
      scope.distinct
    end

    def by_name(scope)
      return scope if @params[:name].blank?

      scope.where("lockers.name ILIKE ?", "%#{sanitize(@params[:name])}%")
    end

    def by_device_id(scope)
      return scope if @params[:device_id].blank?

      scope.where("lockers.device_id ILIKE ?", "%#{sanitize(@params[:device_id])}%")
    end

    def by_company(scope)
      return scope if @params[:company_id].blank?

      scope.where(company_id: @params[:company_id])
    end

    def by_status(scope)
      return scope unless @params[:status].to_s.in?(%w[open closed])

      scope.where(status: @model.statuses.fetch(@params[:status]))
    end

    def by_team(scope)
      return scope if @params[:team_id].blank?

      scope.joins(:teams).where(teams: { id: @params[:team_id] })
    end

    private

    def sanitize(value)
      @model.sanitize_sql_like(value.to_s)
    end
  end
end
