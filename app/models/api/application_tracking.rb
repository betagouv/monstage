module Api
  class ApplicationTracking < ApplicationRecord
    belongs_to :internship_offer
    belongs_to :student, class_name: 'Users::Student', foreign_key: :student_id
    belongs_to :user_operator, class_name: 'Users::Operator', foreign_key: :user_operator_id

    validates :internship_offer_id,
              uniqueness: { scope: %i[internship_offer_id student_id student_generated_id remote_status] }

    enum :remote_status, {
      application_none: 0,
      application_submitted: 5,
      application_approved: 10,
      application_rejected: 15,
      application_canceled: 20
    }
  end
end
