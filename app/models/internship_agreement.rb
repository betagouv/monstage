class InternshipAgreement < ApplicationRecord
  # include AASM
  belongs_to :internship_application

  # validates :start_date, presence: true
  # validates :end_date, presence: true
  # validates :status, presence: true
  # validates :working_hours, presence: true
  # validates :activities, presence: true
  # validates :skills, presence: true
  # validates :evaluation, presence: true

  scope :by_user, lambda { |user:|
    user_application_ids = user.internship_applications
                               .approved
                               .pluck(:id)
    InternshipAgreement.joins(:internship_application)
                       .where('internship_applications.id = ?', user_application_ids)
  }

  # aasm do
  #   state :drafted, initial: true
  #   state :signed_by_employer,
  #         :signed_by_school_manager,
  #         :signed_by_student,
  #         :signed_by_all
  # end
end
