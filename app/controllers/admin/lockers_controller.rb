class Admin::LockersController < Admin::BaseController
  def index
    scope = Locker.includes(:company, :teams)
    scope = scope.where("lockers.name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    scope = scope.where("lockers.device_id ILIKE ?", "%#{params[:device_id]}%") if params[:device_id].present?
    scope = scope.where(company_id: params[:company_id]) if params[:company_id].present?

    scope =
      case params[:status]
      when "open", "closed" then scope.where(status: Locker.statuses.fetch(params[:status]))
      else scope
      end

    if params[:team_id].present?
      scope = scope.joins(:teams).where(teams: { id: params[:team_id] })
    end

    scope = scope.order("lockers.id ASC").distinct

    @pagination = Pagination.from_params(scope, params)
    @lockers = @pagination.records
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

  def show
    @locker = Locker.includes(:company, teams: :users).find(params[:id])
  end
end
