class LockersController < ApplicationController
  include ActivityFilterCollections

  def index
    @lockers = Lockers::Fetcher.call(
      user: current_user,
      params:,
      includes: [:company, :last_status_changed_by]
    )
  end

  def show
    @locker = scope
      .includes(:company, :last_status_changed_by, teams: :users)
      .find(params[:id])

    @locker_actions = LockerActions::Fetcher.call(
      user: current_user,
      params: params.merge(locker_id: @locker.id)
    )
    @companies = scoped_filter_companies
    @users = scoped_filter_users
    @teams = scoped_filter_teams
  end

  def open
    operate_with(Lockers::Operators::Open)
  end

  def close
    operate_with(Lockers::Operators::Close)
  end

  private

  def scope
    Lockers::VisibleTo.call(user: current_user)
  end

  def operate_with(operator)
    locker = scope.find(params[:id])
    operator.call(locker:, user: current_user)
    redirect_to locker_path(locker), notice: t("flash.locker_updated", status: locker.reload.status)
  rescue Lockers::Operators::Base::NotAllowedError
    render_forbidden!(t("errors.forbidden.locker_not_allowed"))
  rescue Lockers::Operators::Base::InvalidStateError => e
    redirect_to locker_path(params[:id]), alert: e.message
  rescue Lockers::Operators::Base::DeviceError => e
    redirect_to locker_path(params[:id]), alert: t("flash.locker_device_error", message: e.message)
  end
end
