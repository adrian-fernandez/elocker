class Admin::CompaniesController < Admin::BaseController
  def index
    @companies = ::Companies::Fetcher.call(params:)
  end
end
