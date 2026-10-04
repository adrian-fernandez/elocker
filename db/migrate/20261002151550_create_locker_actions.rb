class CreateLockerActions < ActiveRecord::Migration[8.1]
  def change
    create_table :locker_actions do |t|
      t.references :locker, null: false, foreign_key: true
      t.references :user, foreign_key: true
      # Snapshot of the locker's owning company at action time (nullable:
      # actions on unassigned lockers — platform-owner testing — have no
      # company). Preserved on transfer so each action keeps its owner
      # context; the composite FK (locker_id, company_id) → lockers uses
      # MATCH SIMPLE and skips when either column is NULL.
      t.bigint :company_id, null: true

      t.integer :action, null: false

      t.timestamps
    end

    add_index :locker_actions, [:locker_id, :created_at]
    add_index :locker_actions, [:user_id, :created_at]
    add_index :locker_actions, [:company_id, :created_at]

    # Pure date-range filters without a locker/user/company predicate hit
    # this one. Common for "all platform activity between X and Y" in the
    # admin global view.
    add_index :locker_actions, :created_at

    add_foreign_key :locker_actions, :companies
  end
end
