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
    add_column :internship_agreements, :activity_scope, :string
    add_column :internship_agreements, :activity_preparation, :string
    add_column :internship_agreements, :activity_schedule, :string
    add_column :internship_agreements, :activity_learnings, :text
    add_column :internship_agreements, :activity_rating, :text
    add_column :internship_agreements, :schedule, :text

    add_column :internship_agreements, :housing, :text
    add_column :internship_agreements, :insurance, :text
    add_column :internship_agreements, :transportation, :text
    add_column :internship_agreements, :food, :text

    add_column :internship_agreements, :terms, :text
  end
end
