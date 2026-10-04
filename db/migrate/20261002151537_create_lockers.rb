class CreateLockers < ActiveRecord::Migration[8.1]
  def change
    # A PhysicalDevice is the hardware. It has a stable device_id and may
    # live through multiple ownership contracts (Lockers). This is the
    # entity eLocker provisions; tenants only ever see the Locker
    # (contract) record.
    create_table :physical_devices do |t|
      t.string :device_id, null: false
      t.string :model

      t.timestamps
    end

    add_index :physical_devices, :device_id, unique: true

    # A Locker is a contract between a PhysicalDevice and a Company for a
    # window of time. ended_at IS NULL means the current contract. company_id
    # nullable means "unassigned" — the device is on the platform but not
    # yet owned by any tenant; only platform-owner users can see and
    # operate it (for testing / provisioning).
    create_table :lockers do |t|
      t.references :physical_device, null: false, foreign_key: true
      t.references :company, null: true, foreign_key: true

      t.string :name, null: false
      t.integer :status, null: false, default: 0

      t.datetime :started_at, null: false
      t.datetime :ended_at

      t.datetime :last_status_changed_at
      t.references :last_status_changed_by,
                   foreign_key: {to_table: :users},
                   null: true

      t.timestamps
    end

    # Only one active (open-ended) contract per physical device. Historical
    # contracts (ended_at IS NOT NULL) can accumulate freely. Note that
    # `t.references :physical_device` already created a plain btree on
    # `physical_device_id` — essential for the ownership-history query
    # (`WHERE physical_device_id = ?`), which never filters by ended_at.
    add_index :lockers, :physical_device_id,
              unique: true,
              where: "ended_at IS NULL",
              name: "index_lockers_on_physical_device_id_active"

    # Hot path for the tenant list: active lockers of a given company.
    # Partial because we never query inactive lockers scoped by company
    # (that's the "ownership history" view, which goes through the device).
    add_index :lockers, :company_id,
              where: "ended_at IS NULL",
              name: "index_lockers_on_company_id_active"

    # Admin filter "closed only / open only" — kept non-partial because
    # eLocker ops do query it over history.
    add_index :lockers, [:company_id, :status]
    add_index :lockers, [:id, :company_id], unique: true
    add_index :lockers, :last_status_changed_at
    add_index :lockers, :ended_at

    # Hardens the time-slice invariant at the DB layer: a historical row
    # must have ended_at strictly after started_at. The model mirrors it
    # for friendly errors, this is the backstop for SQL that bypasses AR.
    add_check_constraint :lockers,
                         "ended_at IS NULL OR ended_at > started_at",
                         name: "lockers_ended_after_started"
  end
end
