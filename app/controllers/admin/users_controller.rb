class Admin::UsersController < Admin::BaseController
  def index
    scope = User.includes(:company, :teams)
    scope = scope.where("users.name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    scope = scope.where(company_id: params[:company_id]) if params[:company_id].present?

    if params[:team_id].present?
      scope = scope.joins(:teams).where(teams: { id: params[:team_id] })
    end

    scope = scope.order("users.id ASC").distinct

    @pagination = Pagination.from_params(scope, params)
    @users = @pagination.records
    @companies = Company.order(:name)
    @teams =
      if params[:company_id].present?
        Team.where(company_id: params[:company_id]).order(:name)
      else
        Team.includes(:company)
          .order("companies.name ASC, teams.name ASC")
          .references(:company)
      end
  end
end
