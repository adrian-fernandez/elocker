module LockersHelper
  # One place to decide what each status / action looks like. Views ask the
  # helper, never hardcode Bootstrap classes next to the business concept —
  # if the palette changes, only this file does.

  STATUS_BADGE_CLASS = {
    "open"   => "text-bg-success",
    "closed" => "text-bg-secondary"
  }.freeze

  ACTION_BADGE_CLASS = {
    "open_request"  => "text-bg-light border",
    "close_request" => "text-bg-light border",
    "opened"        => "text-bg-success",
    "closed"        => "text-bg-secondary"
  }.freeze

  DEFAULT_BADGE_CLASS = "text-bg-light border".freeze

  # Renders a Bootstrap badge for a locker's status. Pass `size: :lg` to get
  # the larger variant used in the show header.
  def locker_status_badge(status, size: nil)
    classes = ["badge", STATUS_BADGE_CLASS.fetch(status.to_s, DEFAULT_BADGE_CLASS)]
    classes << "fs-6" if size == :lg

    tag.span(t("lockers.status.#{status}"), class: classes.join(" "))
  end

  # Renders a Bootstrap badge for a locker action enum value.
  def locker_action_badge(action)
    tag.span(
      t("locker.activity.actions.#{action}"),
      class: "badge #{ACTION_BADGE_CLASS.fetch(action.to_s, DEFAULT_BADGE_CLASS)}"
    )
  end
end
