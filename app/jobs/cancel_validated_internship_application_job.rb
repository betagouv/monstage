class CancelValidatedInternshipApplicationJob < ActiveJob::Base
  queue_as :default

  def perform(internship_application_id:)
    internship_application = InternshipApplication.find(internship_application_id)
    return unless internship_application.validated_by_employer?
    internship_application.expire!
    StudentMailer.internship_application_expired_email(internship_application: internship_application).deliver_now
  end
end