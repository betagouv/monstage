module Api
  class ApplicationTracking < ApplicationRecord
    belongs_to :internship_offer
    belongs_to :student, class_name: 'Users::Student', foreign_key: :student_id, optional: true

    validates :internship_offer_id,
              uniqueness: { scope: %i[internship_offer_id student_id ms3e_student_id remote_status] }

    enum :remote_status, {
      application_none: 0,
      application_submitted: 5,
      application_approved: 10,
      application_rejected: 15,
      application_canceled: 20
    }
  end
end
