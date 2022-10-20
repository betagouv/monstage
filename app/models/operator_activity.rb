class OperatorActivity < ApplicationRecord
  belongs_to :student, class_name: 'Users::Student',
                       foreign_key: 'student_id'
  belongs_to :operator
  belongs_to :internship_offer, class_name: 'InternshipOffers::Api',
                                foreign_key: 'internship_offer_id',
                                optional: true

  validates :account_created, uniqueness: { scope: [:operator_id, :student_id],
                                            message: 'le compte a déjà été créé' }

end
