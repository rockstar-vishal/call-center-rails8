class CreateLeadsCallLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :leads_call_logs do |t|
      t.references :lead, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :status, null: false, foreign_key: true
      t.datetime :ncd
      t.text :comment

      t.timestamps
    end
  end
end
