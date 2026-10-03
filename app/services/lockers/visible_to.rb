module Lockers
  # Returns the Locker relation visible to a given user.
  #
  # - Platform owner (eLocker staff) → every locker.
  # - Tenant user → only lockers whose team they belong to, scoped to their company.
  #
  # Delegates the "is this user elevated?" check to `Users::PlatformOwnerChecker`
  # so the policy stays in one place.
  class VisibleTo < ApplicationService
    def initialize(user:, model: Locker, checker: Users::PlatformOwnerChecker)
      @user = user
      @model = model
      @checker = checker
    end

    def call
      return @model.all if @checker.call(user: @user)

      @model
        .joins(locker_team_permissions: { team: :users })
        .where(users: { id: @user.id })
        .where(company_id: @user.company_id)
        .distinct
    end
  end
end
