class CreateLeads < ActiveRecord::Migration[8.0]
  def change
    create_table :leads do |t|
      t.string :name
      t.references :company, null: false, foreign_key: true
      t.string :email
      t.string :phone
      t.references :project, null: false, foreign_key: true
      t.references :status, null: false, foreign_key: true
      t.text :comment
      t.references :user, null: false, foreign_key: true
      t.datetime :ncd
      t.boolean :crm_created
      t.string :crm_lead_no
      t.text :crm_response

      t.timestamps
    end
  end
end
