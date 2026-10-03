class SessionsController < ApplicationController
  def update
    user = Sessions::SwitchUser.call(user_id: params[:user_id], session:)
    redirect_back_or_to root_path, notice: t("flash.user_switched", name: user.name)
  end
end
