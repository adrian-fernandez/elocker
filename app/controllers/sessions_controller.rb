class SessionsController < ApplicationController
  def update
    user = User.find(params[:user_id])
    session[:user_id] = user.id

    redirect_back_or_to root_path, notice: t("flash.user_switched", name: user.name)
  end
end
