class InternshipAgreement < ApplicationRecord
  belongs_to :internship_application

  # validates :start_date, presence: true
  # validates :end_date, presence: true
  # validates :status, presence: true
  # validates :working_hours, presence: true
  # validates :activities, presence: true
  # validates :skills, presence: true
  # validates :evaluation, presence: true
end
