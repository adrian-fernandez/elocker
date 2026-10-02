class LockersController < ApplicationController
  before_action :set_scope

  def index
    scope = @scope
    scope = scope.where("lockers.name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    scope =
      case params[:status]
      when "open", "closed" then scope.where(status: Locker.statuses.fetch(params[:status]))
      else scope
      end

    scope = scope.order("lockers.id ASC")

    @pagination = Pagination.from_params(scope, params)
    @lockers = @pagination.records
  end

  def show
    @locker = @scope.includes(:company, teams: :users).find(params[:id])
  end

  private

  def set_scope
    @scope =
      if platform_owner?
        Locker.includes(:company)
      else
        Locker
          .joins(locker_team_permissions: { team: :users })
          .where(users: { id: current_user.id })
          .where(company_id: current_user.company_id)
          .includes(:company)
          .distinct
      end
  end
end
