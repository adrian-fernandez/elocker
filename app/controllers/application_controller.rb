class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  stale_when_importmap_changes

  helper_method :current_user, :platform_owner?, :filter_params

  private

  def current_user
    @current_user ||= Sessions::ResolveCurrentUser.call(session:)
  end

  def platform_owner?(user = current_user)
    Users::PlatformOwnerChecker.call(user:)
  end

  def require_platform_owner!
    return if platform_owner?

    render_forbidden!(t("errors.forbidden.forbidden_admin"))
  end

  def render_forbidden!(reason)
    @forbidden_reason = reason
    render "errors/forbidden", status: :forbidden
  end

  def filter_params
    request.query_parameters.except("page", "per_page")
  end
end
