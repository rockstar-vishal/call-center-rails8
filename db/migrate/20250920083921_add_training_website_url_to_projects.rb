class AddTrainingWebsiteUrlToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :training_website_url, :string
    add_column :projects, :training_video, :string
  end
end
