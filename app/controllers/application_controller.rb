class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  stale_when_importmap_changes

  helper_method :current_user, :platform_owner?, :filter_params

  private

  def current_user
    @current_user ||= begin
      user = User.find_by(id: session[:user_id]) if session[:user_id]
      user ||= User.includes(:company).order(:id).first
      session[:user_id] = user.id if user
      user
    end
  end

  def platform_owner?
    current_user&.platform_owner?
  end

  def require_platform_owner!
    return if platform_owner?

    redirect_to lockers_path, alert: t("flash.forbidden_admin")
  end

  def filter_params
    request.query_parameters.except("page", "per_page")
  end
end
