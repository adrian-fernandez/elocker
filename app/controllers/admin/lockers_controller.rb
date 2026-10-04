class Admin::LockersController < Admin::BaseController
  include ActivityFilterCollections
  include LockerOperations

  def index
    @lockers = ::Lockers::Fetcher.call(
      user: current_user,
      params:,
      includes: [:company, :teams, :physical_device, :last_status_changed_by]
    )
    @companies = Company.order(:name)
    @teams = ::Teams::OptionsFor.call(company_id: params[:company_id])
  end

  def show
    @locker = scope
      .includes(:company, :physical_device, :last_status_changed_by, teams: :users)
      .find(params[:id])

    @locker_actions = ::LockerActions::Fetcher.call(
      user: current_user,
      params: params.merge(locker_id: @locker.id)
    )
    @companies = scoped_filter_companies
    @users = scoped_filter_users
    @teams = scoped_filter_teams
  end

  def transfer_form
    @locker = scope.includes(:company, :physical_device).find(params[:id])
    # Only valid tenants, and never the current owner (nothing to transfer
    # if "new" == "current"). For unassigned lockers the current owner is
    # nil, so the full tenant list stays.
    @companies = Company
      .where(platform_owner: false)
      .where.not(id: @locker.company_id)
      .order(:name)
  end

  def transfer
    locker = scope.find(params[:id])
    attrs  = transfer_params
    new_locker = ::Lockers::Transfer.call(
      physical_device: locker.physical_device,
      company:         resolve_target_company(attrs[:company_id]),
      name:            attrs[:name]
    )

    redirect_to admin_locker_path(new_locker),
                notice: t("flash.locker_transferred")
  rescue ::Lockers::Transfer::InvalidTransferError => e
    redirect_to transfer_admin_locker_path(params[:id]), alert: e.message
  end

  private

  def locker_route(locker_or_id)
    admin_locker_path(locker_or_id)
  end

  def transfer_params
    params.permit(:company_id, :name)
  end

  # Translates the submitted company_id into an actual Company or nil
  # (unassigned). Rejects the platform-owner company so a transfer can't
  # drag a locker into eLocker's own "tenancy" — the dropdown already
  # hides it, this is the server-side belt-and-suspenders.
  def resolve_target_company(raw_id)
    return nil if raw_id.blank?

    Company.where(platform_owner: false).find(raw_id)
  end
end
