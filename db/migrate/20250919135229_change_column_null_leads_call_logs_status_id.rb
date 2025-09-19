class ChangeColumnNullLeadsCallLogsStatusId < ActiveRecord::Migration[8.0]
  def change
    change_column_null :leads_call_logs, :status_id, true
  end
end
