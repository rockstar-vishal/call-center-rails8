class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name
      t.string :phone
      t.references :role, null: false, foreign_key: true
      t.string :assignee_uuid
      t.text :assignee_validated

      t.timestamps
    end
  end
end
