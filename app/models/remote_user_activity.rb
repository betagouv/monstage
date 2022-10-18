class RemoteUserActivity < ApplicationRecord
  belongs_to :student, class_name: 'Users::Student',
                       foreign_key: 'student_id'
  belongs_to :operator
  belongs_to :internship_offer, class_name: 'InternshipOffers::Api',
                                foreign_key: 'internship_offer_id',
                                optional: true

  def anonymize
    update_columns(student_id: nil,
                   operator_id: nil,
                   internship_offer_id: nil)
  end
end
