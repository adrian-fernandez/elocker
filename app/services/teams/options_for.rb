module Teams
  # Builds the Team collection used by the admin Users/Lockers filter dropdowns.
  #
  # When `company_id` is supplied the result is a flat, alphabetical list of
  # that company's teams. Without a company filter the result preloads the
  # company so the view can render `optgroup` headings.
  class OptionsFor < ApplicationService
    def initialize(company_id: nil, model: Team)
      @company_id = company_id
      @model = model
    end

    def call
      return @model.where(company_id: @company_id).order(:name) if @company_id.present?

      @model
        .includes(:company)
        .order("companies.name ASC, teams.name ASC")
        .references(:company)
    end
  end
end
