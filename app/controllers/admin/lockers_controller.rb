class Admin::LockersController < Admin::BaseController
  def index
    @lockers = ::Lockers::Fetcher.call(
      user: current_user,
      params: params,
      includes: [:company, :teams]
    )
    @companies = Company.order(:name)
    @teams = ::Teams::OptionsFor.call(company_id: params[:company_id])
  end

  def show
    @locker = ::Lockers::VisibleTo
      .call(user: current_user)
      .includes(:company, teams: :users)
      .find(params[:id])
  end
end
