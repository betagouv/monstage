class AddNameToTutors < ActiveRecord::Migration[6.0]
  def change
    add_column :tutors, :first_name, :string
    add_column :tutors, :last_name, :string
    rename_column :tutors, :tutor_email, :email
    rename_column :tutors, :tutor_phone, :phone
    add_reference :tutors, :organisation, index: true
    change_column :tutors, :employer_id, :bigint, null: true
  end
end
