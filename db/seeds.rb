# db/seeds.rb

puts "Cleaning database..."

LockerAction.delete_all
LockerTeamPermission.delete_all
Locker.delete_all
TeamsUser.delete_all
Team.delete_all
User.delete_all
Company.delete_all

puts "Creating companies..."

elocker_company = Company.create!(
  name: "eLocker",
  platform_owner: true
)

amazon = Company.create!(
  name: "Amazon"
)

dpd = Company.create!(
  name: "DPD"
)

puts "Creating users..."

# Platform owner (eLocker staff) - full access across every tenant.
User.create!(
  name: "Adrian Support",
  company: elocker_company
)

# Amazon staff
alice = User.create!(
  name: "Alice Johnson",
  company: amazon
)

bob = User.create!(
  name: "Bob Smith",
  company: amazon
)

carol = User.create!(
  name: "Carol Williams",
  company: amazon
)

# DPD staff
david = User.create!(
  name: "David Brown",
  company: dpd
)

emma = User.create!(
  name: "Emma Davis",
  company: dpd
)

puts "Creating teams..."

amazon_warehouse = Team.create!(
  name: "Warehouse",
  company: amazon
)

amazon_operations = Team.create!(
  name: "Operations",
  company: amazon
)

amazon_managers = Team.create!(
  name: "Managers",
  company: amazon
)

dpd_drivers = Team.create!(
  name: "Drivers",
  company: dpd
)

dpd_operations = Team.create!(
  name: "Operations",
  company: dpd
)

puts "Assigning users to teams..."

# HABTM join table carries company_id for composite tenant integrity FKs.
TeamsUser.insert_all!(
  [
    {
      user_id: alice.id,
      team_id: amazon_warehouse.id,
      company_id: amazon.id
    },
    {
      user_id: bob.id,
      team_id: amazon_warehouse.id,
      company_id: amazon.id
    },
    {
      user_id: bob.id,
      team_id: amazon_operations.id,
      company_id: amazon.id
    },
    {
      user_id: carol.id,
      team_id: amazon_managers.id,
      company_id: amazon.id
    },
    {
      user_id: david.id,
      team_id: dpd_drivers.id,
      company_id: dpd.id
    },
    {
      user_id: emma.id,
      team_id: dpd_drivers.id,
      company_id: dpd.id
    },
    {
      user_id: emma.id,
      team_id: dpd_operations.id,
      company_id: dpd.id
    }
  ]
)

puts "Creating lockers..."

# Lockers are created with the status that matches the end of their action history.
amazon_locker_1 = Locker.create!(
  name: "Amazon Locker A1",
  device_id: "AMZ-001",
  company: amazon,
  status: :closed
)

amazon_locker_2 = Locker.create!(
  name: "Amazon Locker A2",
  device_id: "AMZ-002",
  company: amazon,
  status: :open
)

amazon_locker_3 = Locker.create!(
  name: "Amazon Locker A3",
  device_id: "AMZ-003",
  company: amazon,
  status: :closed
)

dpd_locker_1 = Locker.create!(
  name: "DPD Locker D1",
  device_id: "DPD-001",
  company: dpd,
  status: :open
)

dpd_locker_2 = Locker.create!(
  name: "DPD Locker D2",
  device_id: "DPD-002",
  company: dpd,
  status: :open
)

puts "Granting team access to lockers..."

now = Time.current

LockerTeamPermission.insert_all!(
  [
    # Amazon
    {
      locker_id: amazon_locker_1.id,
      team_id: amazon_warehouse.id,
      company_id: amazon.id,
      created_at: now,
      updated_at: now
    },
    {
      locker_id: amazon_locker_1.id,
      team_id: amazon_managers.id,
      company_id: amazon.id,
      created_at: now,
      updated_at: now
    },
    {
      locker_id: amazon_locker_2.id,
      team_id: amazon_warehouse.id,
      company_id: amazon.id,
      created_at: now,
      updated_at: now
    },
    {
      locker_id: amazon_locker_2.id,
      team_id: amazon_operations.id,
      company_id: amazon.id,
      created_at: now,
      updated_at: now
    },
    {
      locker_id: amazon_locker_3.id,
      team_id: amazon_managers.id,
      company_id: amazon.id,
      created_at: now,
      updated_at: now
    },
    # DPD
    {
      locker_id: dpd_locker_1.id,
      team_id: dpd_drivers.id,
      company_id: dpd.id,
      created_at: now,
      updated_at: now
    },
    {
      locker_id: dpd_locker_1.id,
      team_id: dpd_operations.id,
      company_id: dpd.id,
      created_at: now,
      updated_at: now
    },
    {
      locker_id: dpd_locker_2.id,
      team_id: dpd_drivers.id,
      company_id: dpd.id,
      created_at: now,
      updated_at: now
    },
    {
      locker_id: dpd_locker_2.id,
      team_id: dpd_operations.id,
      company_id: dpd.id,
      created_at: now,
      updated_at: now
    }
  ]
)

puts "Creating action history..."

# Amazon A1: Alice opened it, then Bob closed it. Currently closed.
LockerAction.create!(
  locker: amazon_locker_1,
  user: alice,
  company: amazon,
  action: :open_request,
  created_at: 2.hours.ago
)

LockerAction.create!(
  locker: amazon_locker_1,
  user: nil,
  company: amazon,
  action: :opened,
  created_at: 2.hours.ago + 2.seconds
)

LockerAction.create!(
  locker: amazon_locker_1,
  user: bob,
  company: amazon,
  action: :close_request,
  created_at: 1.hour.ago
)

LockerAction.create!(
  locker: amazon_locker_1,
  user: nil,
  company: amazon,
  action: :closed,
  created_at: 1.hour.ago + 2.seconds
)

# Amazon A2: Bob requested a close 30 min ago but the locker never responded.
# A request without a matching response is how we represent a failed/pending action.
LockerAction.create!(
  locker: amazon_locker_2,
  user: bob,
  company: amazon,
  action: :close_request,
  created_at: 30.minutes.ago
)

# DPD D1: David requested an open 45 min ago, locker confirmed shortly after.
LockerAction.create!(
  locker: dpd_locker_1,
  user: david,
  company: dpd,
  action: :open_request,
  created_at: 45.minutes.ago
)

LockerAction.create!(
  locker: dpd_locker_1,
  user: nil,
  company: dpd,
  action: :opened,
  created_at: 45.minutes.ago + 2.seconds
)

# DPD D2: device-initiated state change, no user request behind it.
LockerAction.create!(
  locker: dpd_locker_2,
  user: nil,
  company: dpd,
  action: :opened,
  created_at: 1.hour.ago
)

# Backfill last_status_changed_{at,by} on each locker so the "last change"
# column shows the real history time rather than the create-timestamp.
amazon_locker_1.update_columns(last_status_changed_at: 1.hour.ago + 2.seconds, last_status_changed_by_id: bob.id)
amazon_locker_2.update_columns(last_status_changed_at: 2.hours.ago,                 last_status_changed_by_id: nil)
amazon_locker_3.update_columns(last_status_changed_at: amazon_locker_3.created_at,  last_status_changed_by_id: nil)
dpd_locker_1.update_columns(   last_status_changed_at: 45.minutes.ago + 2.seconds,  last_status_changed_by_id: david.id)
dpd_locker_2.update_columns(   last_status_changed_at: 1.hour.ago,                  last_status_changed_by_id: nil)

puts
puts "Seed completed successfully."
puts

puts "Companies: #{Company.count}"
puts "Users: #{User.count}"
puts "Teams: #{Team.count}"
puts "Team memberships: #{TeamsUser.count}"
puts "Lockers: #{Locker.count}"
puts "Locker team permissions: #{LockerTeamPermission.count}"
puts "Locker actions: #{LockerAction.count}"

puts
puts "Users:"
User.includes(:company).find_each do |user|
  tag = user.company.platform_owner? ? "platform owner" : "tenant"
  puts "  #{user.name} -- #{user.company.name} (#{tag})"
end

puts
puts "Lockers:"
Locker.includes(:company).find_each do |locker|
  puts "  #{locker.name} -- #{locker.status} -- #{locker.company.name}"
end
