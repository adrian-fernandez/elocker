# Shared `open` / `close` endpoints for the two locker controllers (admin and
# client). The only thing that differs between the two namespaces is the URL
# the redirect lands on, so subclasses only have to implement `locker_route`.
#
# Error handling for the three operator-raised errors lives here as
# `rescue_from` so the action bodies stay to one line each.
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

  # Subclasses implement this to point at the right locker show in their
  # URL namespace (`locker_path` for the client controller,
  # `admin_locker_path` for the admin one).
  def locker_route(_locker_or_id)
    raise NotImplementedError, "#{self.class} must implement #locker_route"
  end
end
