class CreateLockerActions < ActiveRecord::Migration[8.1]
  def change
    create_table :locker_actions do |t|
      t.references :locker, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.bigint :company_id, null: false

      t.integer :action, null: false

      t.timestamps
    end

    add_index :locker_actions, [:locker_id, :created_at]
    add_index :locker_actions, [:user_id, :created_at]
    add_index :locker_actions, [:company_id, :created_at]

    add_foreign_key :locker_actions, :companies
  end
end
