class AddLanguagesToStudent < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :resume_languages, :text
  end
end
