module LockerActions
  # Returns the LockerAction relation visible to a given user.
  #
  # - Platform owner → every action on the platform.
  # - Tenant user    → only actions on lockers they can see, scoped to their
  #                    company (belt-and-suspenders alongside the composite
  #                    FK that keeps actions inside their tenant).
  #
  # Mirrors the policy of `Lockers::VisibleTo` so the two can never diverge:
  # "if you can see the locker, you can see its actions."
  class VisibleTo < ApplicationService
    def initialize(user:, model: LockerAction, lockers_scope: Lockers::VisibleTo, checker: Users::PlatformOwnerChecker)
      @user = user
      @model = model
      @lockers_scope = lockers_scope
      @checker = checker
    end

    def call
      return @model.all if @checker.call(user: @user)

      @model
        .where(locker_id: @lockers_scope.call(user: @user).select(:id))
        .where(company_id: @user.company_id)
    end
  end
end
