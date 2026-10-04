class SessionsController < ApplicationController
  def update
    user = Sessions::SwitchUser.call(user_id: params[:user_id], session:)
    redirect_back_or_to root_path, notice: t("flash.user_switched", name: user.name)
  end

  # Lazy-loaded dropdown for the navbar switcher. Hitting an endpoint on
  # click (rather than rendering every user on every page) keeps the
  # payload small when the platform has a lot of users.
  def switcher_users
    @companies_with_users = User.grouped_by_company
      .to_a
      .group_by(&:company)
      .sort_by { |company, _| [company.platform_owner? ? 0 : 1, company.name] }

    render partial: "sessions/switcher_users"
  end
end
