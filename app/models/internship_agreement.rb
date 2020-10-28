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

  scope :by_user_and_offers, lambda { |user:, offers: InternshipOffer.all|
    offers_at       = InternshipOffer.arel_table
    applications_at = InternshipApplication.arel_table

    application_ids = offers.kept
                            .includes(:internship_applications)
                            .where(offers_at[:employer_id].eq(user.id))
                            .group(applications_at[:id])
                            .pluck(applications_at[:id])
                            .uniq

    InternshipAgreement.joins(:internship_application)
                       .where(applications_at[:id].in(application_ids))
                       .where(applications_at[:canceled_at].eq(nil))
                       .where.not(applications_at[:approved_at].eq(nil))
  }

  # aasm do
  #   state :drafted, initial: true
  #   state :signed_by_employer,
  #         :signed_by_school_manager,
  #         :signed_by_student,
  #         :signed_by_all
  # end
end
