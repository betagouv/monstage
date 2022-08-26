class AddRoleColumnToTutors < ActiveRecord::Migration[7.0]
  def up
    add_column :tutors, :tutor_role, :string, limit: 70, null: true
  end

  def down
    remove_column :tutors, :tutor_role
  end
end
