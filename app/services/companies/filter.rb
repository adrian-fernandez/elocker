module Companies
  class Filter < ApplicationService
    def initialize(scope:, params:, model: Company)
      @scope = scope
      @params = params
      @model = model
    end

    def call
      scope = @scope
      scope = by_name(scope)
      by_type(scope)
    end

    def by_name(scope)
      return scope if @params[:name].blank?

      scope.where("companies.name ILIKE ?", "%#{sanitize(@params[:name])}%")
    end

    def by_type(scope)
      case @params[:type]
      when "platform" then scope.where(platform_owner: true)
      when "tenant"   then scope.where(platform_owner: false)
      else scope
      end
    end

    private

    def sanitize(value)
      @model.sanitize_sql_like(value.to_s)
    end
  end
end
