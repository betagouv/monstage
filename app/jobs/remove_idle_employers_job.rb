class RemoveIdleEmployersJob < ApplicationJob
  queue_as :default

  def perform(employer_id:)
    employer = Users::Employer.find(employer_id)
    return if employer.nil?

    employer.anonymize(send_email: false)
  end
end
