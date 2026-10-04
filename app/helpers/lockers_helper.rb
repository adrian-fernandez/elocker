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

  # Renders a Bootstrap badge for a LockerAction. Request actions that
  # were forced get the "Force " prefix via a dedicated i18n key; device
  # responses (opened/closed) are never forced.
  def locker_action_badge(locker_action)
    key = locker_action.forced? ? "force_#{locker_action.action}" : locker_action.action
    tag.span(
      t("locker.activity.actions.#{key}"),
      class: "badge #{ACTION_BADGE_CLASS.fetch(locker_action.action, DEFAULT_BADGE_CLASS)}"
    )
  end

  # Renders the locker's current owner either as a company name or as an
  # "Unassigned" warning badge. Centralises the if/else that otherwise
  # repeats across admin views and the shared detail partial.
  def locker_owner_badge(locker)
    return locker.company.name if locker.assigned?

    tag.span(t("common.unassigned"), class: "badge text-bg-warning")
  end

  # Renders a user's name linked to its admin show when `linked` is true,
  # or as plain-text otherwise. Used by last-change cells, activity rows,
  # etc. — anywhere a user name may or may not get a deep link depending
  # on viewer role.
  def linked_user_name(user, linked:)
    if linked
      link_to(user.name, admin_user_path(user), class: "text-decoration-none")
    else
      h(user.name)
    end
  end
end
