module Teams
  # Applies query-string filters to a Team relation.
  #
  # Each filter is its own public method: it receives a scope and returns a
  # scope, idempotent on blank input. `call` composes them in explicit order.
  class Filter < ApplicationService
    def initialize(scope:, params:, model: Team)
      @scope = scope
      @params = params
      @model = model
    end

    def call
      scope = @scope
      scope = by_name(scope)
      scope = by_company(scope)
      scope = by_member_name(scope)
      scope = by_locker_name(scope)
      scope.distinct
    end

    def by_name(scope)
      return scope if @params[:name].blank?

      scope.where("teams.name ILIKE ?", "%#{sanitize(@params[:name])}%")
    end

    def by_company(scope)
      return scope if @params[:company_id].blank?

      scope.where(company_id: @params[:company_id])
    end

    def by_member_name(scope)
      return scope if @params[:members].blank?

      scope.joins(:users).where("users.name ILIKE ?", "%#{sanitize(@params[:members])}%")
    end

    def by_locker_name(scope)
      return scope if @params[:lockers].blank?

      scope.joins(:lockers).where("lockers.name ILIKE ?", "%#{sanitize(@params[:lockers])}%")
    end

    private

    def sanitize(value)
      @model.sanitize_sql_like(value.to_s)
    end
  end
end
