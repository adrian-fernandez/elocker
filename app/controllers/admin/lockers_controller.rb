class Admin::LockersController < Admin::BaseController
  include ActivityFilterCollections
  include LockerOperations

  def index
    @lockers = ::Lockers::Fetcher.call(
      user: current_user,
      params:,
      includes: [:company, :teams, :last_status_changed_by]
    )
    @companies = Company.order(:name)
    @teams = ::Teams::OptionsFor.call(company_id: params[:company_id])
  end

  def show
    @locker = scope
      .includes(:company, :last_status_changed_by, teams: :users)
      .find(params[:id])

    @locker_actions = ::LockerActions::Fetcher.call(
      user: current_user,
      params: params.merge(locker_id: @locker.id)
    )
    @companies = scoped_filter_companies
    @users = scoped_filter_users
    @teams = scoped_filter_teams
  end

  private

  def locker_route(locker_or_id)
    admin_locker_path(locker_or_id)
  end
end
