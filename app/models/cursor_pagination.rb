# Keyset / cursor pagination for append-only logs ordered by (created_at
# DESC, id DESC). Trades the ability to jump to an arbitrary page for
# constant-time "next" queries that don't need COUNT(*). Ideal for the
# activity log where new rows arrive constantly.
class CursorPagination
  include Enumerable

  DEFAULT_LIMIT = 25
  MAX_LIMIT = 100
  LIMIT_OPTIONS = [2, 10, 25, 50].freeze

  attr_reader :limit, :before_cursor, :after_cursor

  def self.from_params(scope, params)
    new(scope, cursor: params[:cursor], limit: params[:per_page])
  end

  def initialize(scope, cursor: nil, limit: nil)
    @scope = scope
    @limit = sanitize_limit(limit)
    @cursor = decode_cursor(cursor)
    @records = nil
  end

  def records
    @records ||= begin
      scope = @scope
      scope = scope.where("locker_actions.created_at < ? OR (locker_actions.created_at = ? AND locker_actions.id < ?)",
                          @cursor[:created_at], @cursor[:created_at], @cursor[:id]) if @cursor

      scope.limit(@limit + 1).to_a.tap do |rows|
        @has_next_page = rows.size > @limit
        rows.pop if @has_next_page
      end
    end
  end

  def each(&block)
    records.each(&block)
  end

  def length = records.length
  alias_method :size, :length
  def empty? = length.zero?

  def has_next_page?
    records
    @has_next_page
  end

  def next_cursor
    last = records.last
    return nil if last.nil? || !has_next_page?

    encode_cursor(created_at: last.created_at, id: last.id)
  end

  private

  def sanitize_limit(raw)
    value = raw.to_i
    return DEFAULT_LIMIT if value <= 0

    [value, MAX_LIMIT].min
  end

  def encode_cursor(created_at:, id:)
    Base64.urlsafe_encode64("#{created_at.iso8601(6)}|#{id}", padding: false)
  end

  def decode_cursor(raw)
    return nil if raw.blank?

    decoded = Base64.urlsafe_decode64(raw)
    created_at_str, id_str = decoded.split("|", 2)
    {created_at: Time.iso8601(created_at_str), id: id_str.to_i}
  rescue ArgumentError
    nil
  end
end
