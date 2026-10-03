module Lockers
  # Returns the Locker relation visible to a given user.
  #
  # - Platform owner (eLocker staff) → every locker.
  # - Tenant user → only lockers whose team they belong to, scoped to their company.
  #
  # Reads naturally at the call site: `Lockers::VisibleTo.call(user: current_user)`.
  # Used by both the list path (via `Lockers::Fetcher`) and the show path.
  class VisibleTo < ApplicationService
    def initialize(user:, model: Locker)
      @user = user
      @model = model
    end

    def call
      return @model.all if @user.platform_owner?

      @model
        .joins(locker_team_permissions: { team: :users })
        .where(users: { id: @user.id })
        .where(company_id: @user.company_id)
        .distinct
    end
  end
end
