class CleaningEmployerJob < ActiveJob::Base
  queue_as :default

  def perform(id)
    employer = Users::Employer.find(id)
    return if employer.nil?
    return if employer.current_sign_in_at.present? &&
              employer.current_sign_in_at >= 2.weeks.ago

    employer.anonymize(send_email: false)
  end
end