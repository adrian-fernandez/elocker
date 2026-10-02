class CreateLockerTeamPermissions < ActiveRecord::Migration[8.1]
  def change
    create_table :locker_team_permissions do |t|
      t.bigint :locker_id, null: false
      t.bigint :team_id, null: false
      t.bigint :company_id, null: false

      t.timestamps
    end

    add_index :locker_team_permissions,
              [:locker_id, :team_id],
              unique: true

    add_index :locker_team_permissions,
              [:locker_id, :company_id]

    add_index :locker_team_permissions,
              [:team_id, :company_id]

    add_foreign_key :locker_team_permissions, :lockers
    add_foreign_key :locker_team_permissions, :teams
    add_foreign_key :locker_team_permissions, :companies
  end
end
