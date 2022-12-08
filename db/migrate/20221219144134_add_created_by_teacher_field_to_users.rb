class AddCreatedByTeacherFieldToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :created_by_teacher, :boolean, default: false
  end
end
