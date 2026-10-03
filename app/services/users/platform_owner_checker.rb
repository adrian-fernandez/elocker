module Users
  # Policy: does this user hold platform-owner privileges?
  #
  # Today the answer is derived from the user's company (one tenant on the
  # platform is marked as the platform owner, and every user in it inherits
  # the role). Tomorrow we may want it finer-grained: a user-level flag, a
  # permission table, a role granted per-team. All of those changes live
  # here — call sites never inspect `user.company.platform_owner` directly.
  class PlatformOwnerChecker < ApplicationService
    def initialize(user:)
      @user = user
    end

    def call
      return false if @user.nil?

      @user.company&.platform_owner == true
    end
  end
end
