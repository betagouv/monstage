class RemoveMoveResumeFieldToRichText < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :resume_educational_background
    remove_column :users, :resume_other
    remove_column :users, :resume_languages
  end
end
