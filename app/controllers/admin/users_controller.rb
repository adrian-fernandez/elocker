class Admin::UsersController < Admin::BaseController
  def index
    @users = ::Users::Fetcher.call(params: params)
    @companies = Company.order(:name)
    @teams = ::Teams::OptionsFor.call(company_id: params[:company_id])
  end

  def show
    @user = User.includes(:company, teams: :lockers).find(params[:id])
  end
end
