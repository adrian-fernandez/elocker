require "rails_helper"

RSpec.describe "Lockers end-to-end flow", type: :system do
  let!(:platform) { create(:user, :platform_owner, name: "Platform Admin") }
  let!(:amazon)   { create(:company, name: "Amazon") }
  let!(:tenant)   { create(:user, name: "Alice Johnson", company: amazon) }

  before do
    team = create(:team, company: amazon)
    device = create(:physical_device, device_id: "AMZ-TEST")
    @locker = create(:locker, physical_device: device, company: amazon, name: "A1", status: :closed)
    create(:teams_user, user: tenant, team: team, company_id: amazon.id)
    create(:locker_team_permission, locker: @locker, team: team, company_id: amazon.id)
  end

  def login_as(user)
    page.driver.submit :patch, "/session", {user_id: user.id}
  end

  it "lets the tenant open then close their locker" do
    login_as(tenant)
    visit "/lockers"

    expect(page).to have_content("A1")

    click_on "A1"
    expect(page).to have_content("Open locker")

    click_on "Open locker"
    expect(page).to have_content("Locker is now open")
    expect(@locker.reload).to be_open

    click_on "Close locker"
    expect(page).to have_content("Locker is now closed")
    expect(@locker.reload).to be_closed
  end

  it "returns 403 when a tenant hits an admin section" do
    login_as(tenant)
    visit "/admin/companies"

    expect(page).to have_content("Access denied")
    expect(page.status_code).to eq(403)
  end
end
