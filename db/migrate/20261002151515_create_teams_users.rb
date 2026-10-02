class CreateTeamsUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :teams_users, id: false do |t|
      t.bigint :team_id, null: false
      t.bigint :user_id, null: false
      t.bigint :company_id, null: false
    end

    add_index :teams_users, [:team_id, :user_id], unique: true
    add_index :teams_users, [:user_id, :team_id]
    add_index :teams_users, [:team_id, :company_id]
    add_index :teams_users, [:user_id, :company_id]

    add_foreign_key :teams_users, :teams
    add_foreign_key :teams_users, :users
    add_foreign_key :teams_users, :companies
  end
end
