# Shared open/close endpoints for the admin and client lockers controllers.
# Subclasses implement `locker_route` to point redirects at the right URL
# namespace. Errors raised by the operator are translated to responses once
# here via `rescue_from` so action bodies stay one-liners.
module LockerOperations
  extend ActiveSupport::Concern

  included do
    rescue_from ::Lockers::Operators::Base::NotAllowedError do
      render_forbidden!(t("errors.forbidden.locker_not_allowed"))
    end

    rescue_from ::Lockers::Operators::Base::InvalidStateError do |e|
      redirect_to locker_route(params[:id]), alert: e.message
    end

    rescue_from ::Lockers::Operators::Base::DeviceError do |e|
      redirect_to locker_route(params[:id]), alert: t("flash.locker_device_error", message: e.message)
    end
  end

  def open
    operate_with(::Lockers::Operators::Open)
  end

  def close
    operate_with(::Lockers::Operators::Close)
  end

  private

  def operate_with(operator)
    locker = scope.find(params[:id])
    operator.call(locker:, user: current_user)
    redirect_to locker_route(locker), notice: t("flash.locker_updated", status: locker.reload.status)
  end

  def scope
    ::Lockers::VisibleTo.call(user: current_user)
  end

  def locker_route(_locker_or_id)
    raise NotImplementedError, "#{self.class} must implement #locker_route"
  end
end
