class LockerAction < ApplicationRecord
  belongs_to :locker
  belongs_to :user, optional: true
  belongs_to :company, optional: true

  REQUEST_ACTIONS = %w[open_request close_request].freeze
  RESPONSE_ACTIONS = %w[opened closed].freeze

  enum :action, {
    open_request: 0,
    close_request: 1,
    opened: 2,
    closed: 3
  }

  validate :company_matches_locker
  validate :user_matches_action_type
  validate :user_belongs_to_company_or_is_platform_owner

  after_create_commit -> { broadcast_refresh_to "lockers" }

  private

  def company_matches_locker
    return if locker.nil?
    return if company_id == locker.company_id

    errors.add(:company_id, "must match the locker's company")
  end

  def user_matches_action_type
    if REQUEST_ACTIONS.include?(action) && user.nil?
      errors.add(:user, "is required for #{action} actions")
    elsif RESPONSE_ACTIONS.include?(action) && user.present?
      errors.add(:user, "must be nil for #{action} (device response)")
    end
  end

  # Prevents a tenant from issuing actions on another tenant's locker even
  # when the (locker_id, company_id) composite FK alone would allow it.
  # Platform-owner users are allowed to act on any tenant's locker.
  def user_belongs_to_company_or_is_platform_owner
    return if user.nil? || company_id.nil?
    return if user.company_id == company_id
    return if Users::PlatformOwnerChecker.call(user:)

    errors.add(:user, "must belong to the action's company or be a platform owner")
  end
end
