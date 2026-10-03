class Admin::TeamsController < Admin::BaseController
  def index
    @teams = ::Teams::Fetcher.call(params: params)
    @companies = Company.order(:name)
  end
end
