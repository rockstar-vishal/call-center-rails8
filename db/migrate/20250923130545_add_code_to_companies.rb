class AddCodeToCompanies < ActiveRecord::Migration[8.0]
  def change
    add_column :companies, :code, :string
    add_column :leads, :code, :string
    add_column :users, :code, :string
  end
end
