require "rails_helper"

RSpec.describe "Device transfer end-to-end", type: :system do
  let!(:platform) { create(:user, :platform_owner, name: "Platform Admin") }
  let!(:amazon)   { create(:company, name: "Amazon") }

  def login_as(user)
    page.driver.submit :patch, "/session", {user_id: user.id}
  end

  it "transfers an unassigned device to a tenant" do
    device = create(:physical_device, device_id: "SPARE-X")
    spare = create(:locker, :unassigned, physical_device: device, name: "SPARE-X")

    login_as(platform)
    visit admin_locker_path(spare)

    click_on "Transfer device"
    select "Amazon", from: "New company"
    fill_in "New locker name", with: "Amazon X"
    click_on "Transfer device"

    expect(page).to have_content("Device transferred")
    new_locker = device.lockers.find_by(ended_at: nil)
    expect(new_locker.company).to eq(amazon)
    expect(new_locker.name).to eq("Amazon X")
    expect(spare.reload.ended_at).to be_present
  end
end
