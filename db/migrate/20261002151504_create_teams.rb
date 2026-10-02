class CreateTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end

    add_index :teams, [:company_id, :name], unique: true
    add_index :teams, [:id, :company_id], unique: true
  end
end
