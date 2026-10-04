class LockerAction < ApplicationRecord
  belongs_to :locker
  belongs_to :user, optional: true
  belongs_to :company, optional: true

  REQUEST_ACTIONS  = %w[open_request close_request].freeze
  RESPONSE_ACTIONS = %w[opened closed].freeze

  enum :action, {
    open_request: 0,
    close_request: 1,
    opened: 2,
    closed: 3
  }

  # The composite FK (locker_id, company_id) → lockers skips its check when
  # either side is NULL (MATCH SIMPLE). This validation closes the gap:
  # whatever company_id we snapshot MUST match the locker's company at save
  # time, so a tenant action can't be mis-attributed to another tenant.
  validate :company_matches_locker

  # Request actions (open_request/close_request) are user-triggered → user
  # must be present. Response actions (opened/closed) are device-reported
  # → user must be nil. Enforces the event-log contract at the model.
  validate :user_matches_action_type

  after_create_commit -> { broadcast_refresh_to "lockers" }

  private

  def company_matches_locker
    return if locker.nil?
    return if company_id == locker.company_id

    errors.add(:company_id,
               "must match the locker's company (#{locker.company_id.inspect})")
  end

  def user_matches_action_type
    if REQUEST_ACTIONS.include?(action) && user.nil?
      errors.add(:user, "is required for #{action} actions")
    elsif RESPONSE_ACTIONS.include?(action) && user.present?
      errors.add(:user, "must be nil for #{action} (device response)")
    end
  end
end
