class UpdateStudentLegalRepresentative2FieldsToInternshipAgreements < ActiveRecord::Migration[7.0]
  def up

      change_table :internship_agreements do |t|
      t.rename  :student_legal_representative_full_name2, :student_legal_representative_2_full_name
      t.rename  :student_legal_representative_email2, :student_legal_representative_2_email
      t.rename  :student_legal_representative_phone2, :student_legal_representative_2_phone
    end
  end

  def down
    change_table :internship_agreements do |t|
      t.rename :student_legal_representative_2_full_name, :student_legal_representative_full_name2
      t.rename :student_legal_representative_2_email, :student_legal_representative_email2
      t.rename :student_legal_representative_2_phone, :student_legal_representative_phone2
    end
  end
end
