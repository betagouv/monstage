class ColLimitsAdjustingForOffers < ActiveRecord::Migration[7.1]
  def up
    change_column :internship_offers, :title, :string, limit: 150
    change_column :internship_offer_infos, :title, :string, limit: 150

    change_column :internship_offers, :tutor_name, :string, limit: 290
    change_column :tutors, :tutor_name, :string, limit: 290
    change_column :internship_offers, :tutor_phone, :string, limit: 100
    change_column :tutors, :tutor_phone, :string, limit: 100
    change_column :internship_offers, :tutor_email, :string, limit: 100
    change_column :tutors, :tutor_email, :string, limit: 100
    change_column :internship_offers, :tutor_role, :string, limit: 150
    change_column :tutors, :tutor_role, :string, limit: 150

    change_column :internship_offers, :employer_website, :string, limit: 560
    change_column :internship_offers, :city, :string, limit: 50
    change_column :practical_infos, :city, :string, limit: 50
    change_column :organisations, :city, :string, limit: 50
    change_column :internship_offers, :street, :string, limit: 3_000
    change_column :practical_infos, :street, :string, limit: 500
    change_column :organisations, :street, :string, limit: 500
    change_column :internship_offers, :zipcode, :string, limit: 5
    change_column :practical_infos, :zipcode, :string, limit: 5
    change_column :organisations, :zipcode, :string, limit: 5

    change_column :internship_offers, :siret, :string, limit: 14
    change_column :organisations, :siret, :string, limit: 14

    change_column :internship_offers, :employer_name, :string, limit: 180
    change_column :organisations, :employer_name, :string, limit: 180

    change_column :internship_offers, :description, :text, limit: 500
    change_column :internship_offers, :employer_description, :string, limit: 250
    change_column :organisations, :employer_description, :string, limit: 250

    change_column :internship_offers, :academy, :text, limit: 160

    change_column :internship_offers, :employer_type, :string, limit: 80

    change_column :internship_offers, :remote_id, :string, limit: 50
    change_column :internship_offers, :permalink, :string, limit: 280
    # -------------------
    change_column :internship_applications, :student_email, :string, limit: 100
    change_column :internship_applications, :student_phone, :string, limit: 683
    change_column :internship_applications, :access_token, :string, limit: 25
    # -------------------
    change_column :internship_agreements, :date_range, :string, limit: 210
    change_column :internship_agreements, :organisation_representative_full_name, :string, limit: 150
    change_column :internship_agreements, :school_representative_full_name, :string, limit: 100
    change_column :internship_agreements, :student_full_name, :string, limit: 100
    change_column :internship_agreements, :student_class_room, :string, limit: 27
    change_column :internship_agreements, :student_school, :string, limit: 140
    change_column :internship_agreements, :tutor_full_name, :string, limit: 271
    change_column :internship_agreements, :siret, :string, limit: 145
    change_column :internship_agreements, :tutor_role, :string, limit: 150
    change_column :internship_agreements, :tutor_email, :string, limit: 85
    change_column :internship_agreements, :organisation_representative_role, :string, limit: 150
    change_column :internship_agreements, :student_address, :string, limit: 500
    change_column :internship_agreements, :student_phone, :string, limit: 20
    change_column :internship_agreements, :school_representative_phone, :string, limit: 20
    change_column :internship_agreements, :student_refering_teacher_phone, :string, limit: 20
    change_column :internship_agreements, :student_legal_representative_email, :string, limit: 100
    change_column :internship_agreements, :student_refering_teacher_email, :string, limit: 100
    change_column :internship_agreements, :student_legal_representative_full_name, :string, limit: 100
    change_column :internship_agreements, :student_refering_teacher_full_name, :string, limit: 100
    change_column :internship_agreements, :student_legal_representative_phone, :string, limit: 50
    change_column :internship_agreements, :student_legal_representative_2_full_name, :string, limit: 100
    change_column :internship_agreements, :student_legal_representative_2_email, :string, limit: 100
    change_column :internship_agreements, :student_legal_representative_2_phone, :string, limit: 20
    change_column :internship_agreements, :school_representative_role, :string, limit: 100
    change_column :internship_agreements, :school_representative_email, :string, limit: 100
  end
  def down; end
end
