# Companies/users/teams collections for the activity filter dropdowns.
# Platform owners see everything grouped by company; tenants only see
# their own company (the locker list is already scoped by VisibleTo at
# the controller level).
module ActivityFilterCollections
  extend ActiveSupport::Concern

  private

  def scoped_filter_companies
    return nil unless platform_owner?

    Company.order(platform_owner: :desc, name: :asc)
  end

  def scoped_filter_users
    platform_owner? ? User.grouped_by_company : current_user.company.users.order(:name)
  end

  def scoped_filter_teams
    platform_owner? ? Team.grouped_by_company : current_user.company.teams.order(:name)
  end
end
