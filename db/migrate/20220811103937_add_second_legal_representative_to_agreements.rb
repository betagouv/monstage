class AddSecondLegalRepresentativeToAgreements < ActiveRecord::Migration[7.0]
  def up
    add_column :internship_agreements, :student_legal_representative_full_name2,
               :string,
               limit: 120,
               null: true
    add_column :internship_agreements, :student_legal_representative_email2,
               :string,
               limit: 70,
               null: true
    add_column :internship_agreements, :student_legal_representative_phone2,
               :string,
               limit: 20,
               null: true
    add_column :internship_agreements, :school_representative_role,
               :string,
               limit: 60,
               null: true
    add_column :internship_agreements, :school_representative_email,
               :string,
               limit: 100,
               null: true
  end

  def down
    remove_column :internship_agreements, :student_legal_representative_full_name2
    remove_column :internship_agreements, :student_legal_representative_email2
    remove_column :internship_agreements, :student_legal_representative_phone2
    remove_column :internship_agreements, :school_representative_role
    remove_column :internship_agreements, :school_representative_email
  end
end
