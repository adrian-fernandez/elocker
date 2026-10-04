module Users
  class Filter < ApplicationService
    def initialize(scope:, params:, model: User)
      @scope = scope
      @params = params
      @model = model
    end

    def call
      scope = @scope
      scope = by_name(scope)
      scope = by_company(scope)
      scope = by_team(scope)
      scope.distinct
    end

    def by_name(scope)
      return scope if @params[:name].blank?

      scope.where("users.name ILIKE ?", "%#{sanitize(@params[:name])}%")
    end

    def by_company(scope)
      return scope if @params[:company_id].blank?

      scope.where(company_id: @params[:company_id])
    end

    def by_team(scope)
      return scope if @params[:team_id].blank?

      scope.joins(:teams).where(teams: {id: @params[:team_id]})
    end

    private

    def sanitize(value)
      @model.sanitize_sql_like(value.to_s)
    end
  end
end
