class CreateLockers < ActiveRecord::Migration[8.1]
  def change
    create_table :lockers do |t|
      t.string :name, null: false
      t.string :device_id, null: false
      t.integer :status, null: false, default: 0
      t.references :company, null: false, foreign_key: true

      # Separate from updated_at so edits to name/device_id/etc. don't bump
      # the "last state change" clock. Nullable so the fresh-create path can
      # fill it from the response action's time instead of Time.now.
      t.datetime :last_status_changed_at
      t.references :last_status_changed_by,
                   foreign_key: { to_table: :users },
                   null: true

      t.timestamps
    end

    add_index :lockers, :device_id, unique: true
    add_index :lockers, [:company_id, :status]
    add_index :lockers, [:id, :company_id], unique: true
    add_index :lockers, :last_status_changed_at
  end
end
