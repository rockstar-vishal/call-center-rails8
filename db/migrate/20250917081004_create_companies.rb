class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.integer :lead_limit
      t.string :domain
      t.string :crm_domain

      t.timestamps
    end
  end
end
