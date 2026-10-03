class Admin::LockersController < Admin::BaseController
  def index
    @lockers = ::Lockers::Fetcher.call(
      user: current_user,
      params:,
      includes: [:company, :teams]
    )
    @companies = Company.order(:name)
    @teams = ::Teams::OptionsFor.call(company_id: params[:company_id])
  end

  def show
    @locker = scope
      .includes(:company, teams: :users, locker_actions: :user)
      .find(params[:id])
  end

  def open
    operate_with(::Lockers::Operators::Open)
  end

  def close
    operate_with(::Lockers::Operators::Close)
  end

  private

  def scope
    ::Lockers::VisibleTo.call(user: current_user)
  end

  def operate_with(operator)
    locker = scope.find(params[:id])
    operator.call(locker:, user: current_user)
    redirect_to admin_locker_path(locker), notice: t("flash.locker_updated", status: locker.reload.status)
  rescue ::Lockers::Operators::Base::NotAllowedError
    render_forbidden!(t("errors.forbidden.locker_not_allowed"))
  rescue ::Lockers::Operators::Base::InvalidStateError => e
    redirect_to admin_locker_path(params[:id]), alert: e.message
  rescue ::Lockers::Operators::Base::DeviceError => e
    redirect_to admin_locker_path(params[:id]), alert: t("flash.locker_device_error", message: e.message)
  end
end
