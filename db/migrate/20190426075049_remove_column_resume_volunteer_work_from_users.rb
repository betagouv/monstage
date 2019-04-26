class RemoveColumnResumeVolunteerWorkFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :resume_volunteer_work
  end
end
