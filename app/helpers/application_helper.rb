module ApplicationHelper
  # Counts the query-string filters currently applied. Used by the
  # filters toggle to badge the button and decide if the collapse
  # starts expanded.
  def active_filters_count
    filter_params.compact_blank.size
  end
end
