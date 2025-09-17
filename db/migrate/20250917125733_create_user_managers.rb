class CreateUserManagers < ActiveRecord::Migration[8.0]
  def change
    create_table :user_managers do |t|
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.references :manager, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    
    # Add unique constraint to prevent duplicate manager-user pairs
    add_index :user_managers, [:user_id, :manager_id], unique: true
    
    # Add constraint to prevent self-management
    add_check_constraint :user_managers, "user_id != manager_id", name: "no_self_management"
  end
end
