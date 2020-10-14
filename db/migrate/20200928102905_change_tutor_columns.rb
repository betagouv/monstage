class ChangeTutorColumns < ActiveRecord::Migration[6.0]
  def change
    rename_column :mentors, :name, :tutor_name
    rename_column :mentors, :phone, :tutor_phone
    rename_column :mentors, :email, :tutor_email
  end
end
