class HomeController < ApplicationController
  def index
    if platform_owner?
      redirect_to admin_companies_path
    else
      redirect_to lockers_path
    end
  end
end
