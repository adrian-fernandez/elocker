class ActivityController < ApplicationController
  include ActivityFilterCollections

  def index
    @locker_actions = LockerActions::Fetcher.call(user: current_user, params:)
    @lockers        = Lockers::VisibleTo.call(user: current_user).order(:name)
    @companies      = scoped_filter_companies
    @users          = scoped_filter_users
    @teams          = scoped_filter_teams
  end
end
