module Lockers
  # Returns the Locker contracts visible to a given user.
  #
  # - Platform owner → every active contract, including unassigned ones
  #   (company_id NULL) so platform can test devices before they're sold.
  # - Tenant user → only active contracts of their company, further filtered
  #   by team permissions.
  #
  # Historical contracts (ended_at IS NOT NULL) are deliberately excluded —
  # they're audit records surfaced through the PhysicalDevice detail view,
  # not the regular locker screens.
  class VisibleTo < ApplicationService
    def initialize(user:, model: Locker, checker: Users::PlatformOwnerChecker)
      @user = user
      @model = model
      @checker = checker
    end

    def call
      base = @model.active
      return base if @checker.call(user: @user)

      base
        .joins(locker_team_permissions: {team: :users})
        .where(users: {id: @user.id})
        .where(company_id: @user.company_id)
        .distinct
    end
  end
end
