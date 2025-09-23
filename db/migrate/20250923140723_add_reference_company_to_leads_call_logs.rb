class AddReferenceCompanyToLeadsCallLogs < ActiveRecord::Migration[8.0]
  def change
    add_reference :leads_call_logs, :company, null: false, foreign_key: true
  end
end
