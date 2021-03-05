class AddFieldsToInternshipAgreements < ActiveRecord::Migration[6.0]
  def change
    add_column :internship_agreements, :organisation_representative_full_name, :string
    add_column :internship_agreements, :school_representative_full_name, :string
    add_column :internship_agreements, :student_full_name, :string
    add_column :internship_agreements, :student_class_room, :string
    add_column :internship_agreements, :student_school, :string
    add_column :internship_agreements, :tutor_full_name, :string
    add_column :internship_agreements, :main_teacher_full_name, :string
    add_column :internship_agreements, :doc_date, :date
  end
end
