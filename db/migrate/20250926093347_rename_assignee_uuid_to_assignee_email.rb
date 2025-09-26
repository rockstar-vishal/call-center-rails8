class RenameAssigneeUuidToAssigneeEmail < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :assignee_uuid, :assignee_email
  end
end
