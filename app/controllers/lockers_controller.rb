class LockersController < ApplicationController
  def index
    @lockers = Lockers::Fetcher.call(
      user: current_user,
      params: params,
      includes: [:company]
    )
  end

  def show
    @locker = Lockers::VisibleTo
      .call(user: current_user)
      .includes(:company, teams: :users)
      .find(params[:id])
  end
end
