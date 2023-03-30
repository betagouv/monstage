class AddStudentPhoneToInternshipApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :internship_applications, :student_phone, :string
    add_column :internship_applications, :student_email, :string
  end
end
