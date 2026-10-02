class Admin::CompaniesController < Admin::BaseController
  def index
    scope = Company.includes(:users, :teams, :lockers)
    scope = scope.where("companies.name ILIKE ?", "%#{params[:name]}%") if params[:name].present?

    scope =
      case params[:type]
      when "platform" then scope.where(platform_owner: true)
      when "tenant"   then scope.where(platform_owner: false)
      else scope
      end

    scope = scope.order(platform_owner: :desc, name: :asc)

    @pagination = Pagination.from_params(scope, params)
    @companies = @pagination.records
  end
end
