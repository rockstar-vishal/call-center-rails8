class AddChurnCountToLeads < ActiveRecord::Migration[8.0]
  def change
    add_column :leads, :churn_count, :integer
  end
end
