class CreateLockers < ActiveRecord::Migration[8.1]
  def change
    create_table :lockers do |t|
      t.string :name, null: false
      t.string :device_id, null: false
      t.integer :status, null: false, default: 0
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end

    add_index :lockers, :device_id, unique: true
    add_index :lockers, [:company_id, :status]
    add_index :lockers, [:id, :company_id], unique: true
  end
end
