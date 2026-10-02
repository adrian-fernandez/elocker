class Admin::TeamsController < Admin::BaseController
  def index
    scope = Team.includes(:company, :users, :lockers)
    scope = scope.where("teams.name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    scope = scope.where(company_id: params[:company_id]) if params[:company_id].present?

    if params[:members].present?
      scope = scope.joins(:users).where("users.name ILIKE ?", "%#{params[:members]}%")
    end

    if params[:lockers].present?
      scope = scope.joins(:lockers).where("lockers.name ILIKE ?", "%#{params[:lockers]}%")
    end

    scope = scope.order("teams.id ASC").distinct

    @pagination = Pagination.from_params(scope, params)
    @teams = @pagination.records
    @companies = Company.order(:name)
  end
end
