class Pagination
  DEFAULT_PER_PAGE = 25
  PER_PAGE_OPTIONS = [2, 10, 25, 50].freeze
  MAX_PER_PAGE = 100

  attr_reader :page, :per_page, :total

  def self.from_params(scope, params)
    new(scope, params[:page], params[:per_page])
  end

  def initialize(scope, raw_page, raw_per_page)
    @scope = scope
    @per_page = sanitize_per_page(raw_per_page)
    @total = scope.except(:order, :select).count
    @page = sanitize_page(raw_page)
  end

  def records
    @records ||= @scope.limit(@per_page).offset(offset)
  end

  def offset
    (@page - 1) * @per_page
  end

  def page_count
    [(@total.to_f / @per_page).ceil, 1].max
  end

  def first_page?
    @page <= 1
  end

  def last_page?
    @page >= page_count
  end

  def range_from
    return 0 if @total.zero?

    offset + 1
  end

  def range_to
    [offset + @per_page, @total].min
  end

  private

  def sanitize_per_page(raw)
    value = raw.to_i
    return DEFAULT_PER_PAGE if value <= 0

    [value, MAX_PER_PAGE].min
  end

  def sanitize_page(raw)
    value = raw.to_i
    return 1 if value <= 0

    [value, page_count].min
  end
end
