class AddNewColumnsToAgreements < ActiveRecord::Migration[7.0]
  def up
    add_column :internship_agreements, :siret,
               :string,
               limit: 16,
               null: true
    add_column :internship_agreements, :tutor_role,
               :string,
               limit: 100,
               null: true
    add_column :internship_agreements, :tutor_email,
               :string,
               limit: 80,
               null: true
    add_column :internship_agreements, :organisation_representative_role,
               :string,
               limit: 100,
               null: true
    add_column :internship_agreements, :student_address,
               :string,
               limit: 250,
               null: true
    add_column :internship_agreements, :student_phone,
               :string,
               limit: 20,
               null: true
    add_column :internship_agreements, :school_representative_phone,
               :string,
               limit: 20,
               null: true
    add_column :internship_agreements, :student_refering_teacher_phone,
               :string,
               limit: 20,
               null: true
    add_column :internship_agreements, :student_legal_representative_email,
               :string,
               limit: 60,
               null: true
    add_column :internship_agreements, :student_refering_teacher_email,
               :string,
               limit: 60,
               null: true
    add_column :internship_agreements, :student_legal_representative_full_name,
               :string,
               limit: 120,
               null: true
    add_column :internship_agreements, :student_refering_teacher_full_name,
               :string,
               limit: 120,
               null: true
    add_column :internship_agreements, :student_legal_representative_phone,
               :string,
               limit: 20,
               null: true

  end

  def down
    remove_column :internship_agreements, :siret
    remove_column :internship_agreements, :student_address
    remove_column :internship_agreements, :student_phone
    remove_column :internship_agreements, :school_representative_phone
    remove_column :internship_agreements, :student_refering_teacher_phone
    remove_column :internship_agreements, :student_legal_representative_email
    remove_column :internship_agreements, :student_refering_teacher_email
    remove_column :internship_agreements, :student_legal_representative_full_name
    remove_column :internship_agreements, :student_refering_teacher_full_name
    remove_column :internship_agreements, :student_legal_representative_phone
    remove_column :internship_agreements, :tutor_role
    remove_column :internship_agreements, :tutor_email
    remove_column :internship_agreements, :organisation_representative_role
  end
end
