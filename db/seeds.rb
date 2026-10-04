# db/seeds.rb

# Everything happens inside one transaction so a partial failure never leaves
# the DB half-cleaned / half-populated. Idempotent on re-run via the
# delete_all cascade at the top.
ActiveRecord::Base.transaction do
puts "Cleaning database..."

LockerAction.delete_all
LockerTeamPermission.delete_all
Locker.delete_all
PhysicalDevice.delete_all
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
alice = User.create!(name: "Alice Johnson",  company: amazon)
bob   = User.create!(name: "Bob Smith",      company: amazon)
carol = User.create!(name: "Carol Williams", company: amazon)

# DPD staff
david = User.create!(name: "David Brown", company: dpd)
emma  = User.create!(name: "Emma Davis",  company: dpd)

puts "Creating teams..."

amazon_warehouse  = Team.create!(name: "Warehouse",  company: amazon)
amazon_operations = Team.create!(name: "Operations", company: amazon)
amazon_managers   = Team.create!(name: "Managers",   company: amazon)

dpd_drivers    = Team.create!(name: "Drivers",    company: dpd)
dpd_operations = Team.create!(name: "Operations", company: dpd)

puts "Assigning users to teams..."

TeamsUser.insert_all!([
  {user_id: alice.id, team_id: amazon_warehouse.id,  company_id: amazon.id},
  {user_id: bob.id,   team_id: amazon_warehouse.id,  company_id: amazon.id},
  {user_id: bob.id,   team_id: amazon_operations.id, company_id: amazon.id},
  {user_id: carol.id, team_id: amazon_managers.id,   company_id: amazon.id},
  {user_id: david.id, team_id: dpd_drivers.id,       company_id: dpd.id},
  {user_id: emma.id,  team_id: dpd_drivers.id,       company_id: dpd.id},
  {user_id: emma.id,  team_id: dpd_operations.id,    company_id: dpd.id}
])

puts "Registering physical devices..."

# Each physical device gets registered once and lives through N locker contracts.
amz_001 = PhysicalDevice.create!(device_id: "AMZ-001", model: "SmartLock-24")
amz_002 = PhysicalDevice.create!(device_id: "AMZ-002", model: "SmartLock-24")
amz_003 = PhysicalDevice.create!(device_id: "AMZ-003", model: "SmartLock-24")
dpd_001 = PhysicalDevice.create!(device_id: "DPD-001", model: "SmartLock-24")
dpd_002 = PhysicalDevice.create!(device_id: "DPD-002", model: "SmartLock-24")

# Two spare devices not yet contracted — only platform owner sees these.
spare_a = PhysicalDevice.create!(device_id: "SPARE-A", model: "SmartLock-24")
spare_b = PhysicalDevice.create!(device_id: "SPARE-B", model: "SmartLock-24-XL")

puts "Opening current locker contracts..."

now = Time.current

amazon_locker_1 = Locker.create!(
  physical_device: amz_001, company: amazon,
  name: "Amazon Locker A1", status: :closed, started_at: 30.days.ago
)
amazon_locker_2 = Locker.create!(
  physical_device: amz_002, company: amazon,
  name: "Amazon Locker A2", status: :open, started_at: 30.days.ago
)
amazon_locker_3 = Locker.create!(
  physical_device: amz_003, company: amazon,
  name: "Amazon Locker A3", status: :closed, started_at: 30.days.ago
)
dpd_locker_1 = Locker.create!(
  physical_device: dpd_001, company: dpd,
  name: "DPD Locker D1", status: :open, started_at: 30.days.ago
)
dpd_locker_2 = Locker.create!(
  physical_device: dpd_002, company: dpd,
  name: "DPD Locker D2", status: :open, started_at: 30.days.ago
)

# Unassigned (available) lockers — only platform owner can see/operate.
Locker.create!(
  physical_device: spare_a, company: nil,
  name: "SPARE-A", status: :closed, started_at: now
)
Locker.create!(
  physical_device: spare_b, company: nil,
  name: "SPARE-B", status: :closed, started_at: now
)

puts "Granting team access to lockers..."

LockerTeamPermission.insert_all!([
  {locker_id: amazon_locker_1.id, team_id: amazon_warehouse.id,  company_id: amazon.id, created_at: now, updated_at: now},
  {locker_id: amazon_locker_1.id, team_id: amazon_managers.id,   company_id: amazon.id, created_at: now, updated_at: now},
  {locker_id: amazon_locker_2.id, team_id: amazon_warehouse.id,  company_id: amazon.id, created_at: now, updated_at: now},
  {locker_id: amazon_locker_2.id, team_id: amazon_operations.id, company_id: amazon.id, created_at: now, updated_at: now},
  {locker_id: amazon_locker_3.id, team_id: amazon_managers.id,   company_id: amazon.id, created_at: now, updated_at: now},
  {locker_id: dpd_locker_1.id,    team_id: dpd_drivers.id,       company_id: dpd.id,    created_at: now, updated_at: now},
  {locker_id: dpd_locker_1.id,    team_id: dpd_operations.id,    company_id: dpd.id,    created_at: now, updated_at: now},
  {locker_id: dpd_locker_2.id,    team_id: dpd_drivers.id,       company_id: dpd.id,    created_at: now, updated_at: now},
  {locker_id: dpd_locker_2.id,    team_id: dpd_operations.id,    company_id: dpd.id,    created_at: now, updated_at: now}
])

puts "Creating action history..."

# Amazon A1: Alice opened it, then Bob closed it. Currently closed.
LockerAction.create!(locker: amazon_locker_1, user: alice, company: amazon, action: :open_request,  created_at: 2.hours.ago)
LockerAction.create!(locker: amazon_locker_1, user: nil,   company: amazon, action: :opened,        created_at: 2.hours.ago + 2.seconds)
LockerAction.create!(locker: amazon_locker_1, user: bob,   company: amazon, action: :close_request, created_at: 1.hour.ago)
LockerAction.create!(locker: amazon_locker_1, user: nil,   company: amazon, action: :closed,        created_at: 1.hour.ago + 2.seconds)

# Amazon A2: Bob requested a close 30 min ago but the locker never responded.
LockerAction.create!(locker: amazon_locker_2, user: bob, company: amazon, action: :close_request, created_at: 30.minutes.ago)

# DPD D1: David requested an open 45 min ago, locker confirmed shortly after.
LockerAction.create!(locker: dpd_locker_1, user: david, company: dpd, action: :open_request, created_at: 45.minutes.ago)
LockerAction.create!(locker: dpd_locker_1, user: nil,   company: dpd, action: :opened,       created_at: 45.minutes.ago + 2.seconds)

# DPD D2: device-initiated state change.
LockerAction.create!(locker: dpd_locker_2, user: nil, company: dpd, action: :opened, created_at: 1.hour.ago)

# Backfill last_status_changed_{at,by} on each locker.
amazon_locker_1.update_columns(last_status_changed_at: 1.hour.ago + 2.seconds,     last_status_changed_by_id: bob.id)
amazon_locker_2.update_columns(last_status_changed_at: 2.hours.ago,                last_status_changed_by_id: nil)
amazon_locker_3.update_columns(last_status_changed_at: amazon_locker_3.created_at, last_status_changed_by_id: nil)
dpd_locker_1.update_columns(last_status_changed_at: 45.minutes.ago + 2.seconds, last_status_changed_by_id: david.id)
dpd_locker_2.update_columns(last_status_changed_at: 1.hour.ago,                 last_status_changed_by_id: nil)

puts
puts "Seed completed successfully."
puts

puts "Companies: #{Company.count}"
puts "Users: #{User.count}"
puts "Teams: #{Team.count}"
puts "Team memberships: #{TeamsUser.count}"
puts "Physical devices: #{PhysicalDevice.count}"
puts "Lockers (active): #{Locker.active.count} (unassigned: #{Locker.active.unassigned.count})"
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
Locker.active.includes(:company, :physical_device).find_each do |locker|
  owner = locker.unassigned? ? "UNASSIGNED" : locker.company.name
  puts "  #{locker.name} [#{locker.device_id}] -- #{locker.status} -- #{owner}"
end
end # ActiveRecord::Base.transaction
