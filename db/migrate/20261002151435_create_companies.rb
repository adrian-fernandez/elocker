class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.boolean :platform_owner, null: false, default: false

      # Counter caches so the admin dashboard shows the three counts
      # without issuing a SELECT COUNT per company per column (which at
      # scale would be 3 × N queries for an unpaginated list).
      t.integer :users_count,   null: false, default: 0
      t.integer :teams_count,   null: false, default: 0
      t.integer :lockers_count, null: false, default: 0

      t.timestamps
    end

    # Exactly one platform-owner company — DB-level invariant.
    add_index :companies, :platform_owner, unique: true, where: "platform_owner = TRUE"

    # Hot-path: admin dashboards sort by name ASC.
    add_index :companies, :name
  end
end
