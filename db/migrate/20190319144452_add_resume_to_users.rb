class AddResumeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :resume_educational_background, :text
    add_column :users, :resume_volunteer_work, :text
    add_column :users, :resume_other, :text
  end
end
