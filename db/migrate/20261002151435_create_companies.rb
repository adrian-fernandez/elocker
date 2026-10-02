class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.boolean :platform_owner, null: false, default: false

      t.timestamps
    end

    add_index :companies, :platform_owner, unique: true, where: "platform_owner = TRUE"
  end
end
