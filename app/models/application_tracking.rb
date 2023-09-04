class ApplicationTracking < ApplicationRecord
  belongs_to :internship_offer
  belongs_to :student, class_name: 'Users::Student', foreign_key: :student_id
  belongs_to :operator, class_name: 'Users::Operator', foreign_key: :operator_id

  enum :remote_status, {
    application_submitted: 5,
    application_approved: 10,
    application_rejected: 15,
    application_canceled: 20
  }
end
