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
                   foreign_key: { to_table: :users },
                   null: true

      t.timestamps
    end

    # Only one active (open-ended) contract per physical device. Historical
    # contracts (ended_at IS NOT NULL) can accumulate freely.
    add_index :lockers, :physical_device_id,
              unique: true,
              where: "ended_at IS NULL",
              name: "index_lockers_on_physical_device_id_active"

    add_index :lockers, [ :company_id, :status ]
    add_index :lockers, [ :id, :company_id ], unique: true
    add_index :lockers, :last_status_changed_at
    add_index :lockers, :ended_at
  end
end
