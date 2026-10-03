# Builds the collections that back the activity table's filter dropdowns.
# Scope rule: platform owners see every user and team, grouped by company;
# tenants only see users and teams of their own company. The locker list
# is already scoped by `Lockers::VisibleTo` at the controller level.
module ActivityFilterCollections
  extend ActiveSupport::Concern

  private

  # Companies the current viewer can filter by. Tenants only ever see
  # actions from their own company (enforced by VisibleTo + the composite
  # FK), so there's nothing meaningful to pick — return nil to hide the
  # dropdown in the view.
  def scoped_filter_companies
    return nil unless platform_owner?

    Company.order(platform_owner: :desc, name: :asc)
  end

  def scoped_filter_users
    if platform_owner?
      User.includes(:company)
        .order("companies.name ASC, users.name ASC")
        .references(:company)
    else
      current_user.company.users.order(:name)
    end
  end

  def scoped_filter_teams
    if platform_owner?
      Team.includes(:company)
        .order("companies.name ASC, teams.name ASC")
        .references(:company)
    else
      current_user.company.teams.order(:name)
    end
  end
end
