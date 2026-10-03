class Admin::PhysicalDevicesController < Admin::BaseController
  def index
    @physical_devices = PhysicalDevice.includes(lockers: :company).order(:device_id)
  end

  def show
    @physical_device = PhysicalDevice
      .includes(lockers_newest_first: [:company, :locker_actions])
      .find(params[:id])
    @ownership_history = @physical_device.lockers_newest_first
  end
end
