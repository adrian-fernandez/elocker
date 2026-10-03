class AddTenantIntegrityConstraints < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      ALTER TABLE teams_users
      ADD CONSTRAINT teams_users_user_company_fk
      FOREIGN KEY (user_id, company_id)
      REFERENCES users (id, company_id)
    SQL

    execute <<~SQL
      ALTER TABLE teams_users
      ADD CONSTRAINT teams_users_team_company_fk
      FOREIGN KEY (team_id, company_id)
      REFERENCES teams (id, company_id)
    SQL

    execute <<~SQL
      ALTER TABLE locker_team_permissions
      ADD CONSTRAINT locker_team_permissions_locker_company_fk
      FOREIGN KEY (locker_id, company_id)
      REFERENCES lockers (id, company_id)
    SQL

    execute <<~SQL
      ALTER TABLE locker_team_permissions
      ADD CONSTRAINT locker_team_permissions_team_company_fk
      FOREIGN KEY (team_id, company_id)
      REFERENCES teams (id, company_id)
    SQL

    # locker_actions.(locker_id, company_id) must match the locker row so
    # we never attribute an action to a locker outside its own tenant.
    #
    # We intentionally do NOT add a composite FK on (user_id, company_id)
    # here: platform-owner (eLocker) users operate lockers of OTHER
    # companies, so their users.company_id is deliberately different from
    # the action's company_id. The simple FK on user_id is enough.
    execute <<~SQL
      ALTER TABLE locker_actions
      ADD CONSTRAINT locker_actions_locker_company_fk
      FOREIGN KEY (locker_id, company_id)
      REFERENCES lockers (id, company_id)
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE locker_actions
      DROP CONSTRAINT locker_actions_locker_company_fk
    SQL

    execute <<~SQL
      ALTER TABLE teams_users
      DROP CONSTRAINT teams_users_user_company_fk
    SQL

    execute <<~SQL
      ALTER TABLE teams_users
      DROP CONSTRAINT teams_users_team_company_fk
    SQL

    execute <<~SQL
      ALTER TABLE locker_team_permissions
      DROP CONSTRAINT locker_team_permissions_locker_company_fk
    SQL

    execute <<~SQL
      ALTER TABLE locker_team_permissions
      DROP CONSTRAINT locker_team_permissions_team_company_fk
    SQL
  end
end
