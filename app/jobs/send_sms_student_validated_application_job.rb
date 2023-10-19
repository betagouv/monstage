# frozen_string_literal: true

class SendSmsStudentValidatedApplicationJob < ApplicationJob
  queue_as :default

  def perform(internship_application_id)
    internship_application = InternshipApplication.find(internship_application_id)
    url = internship_application.sgid_short_url
    phone = internship_application.student_phone

    if phone.gsub(' ', '').size == 10
      phone = "+33#{phone[1..-1]}"

      message = "Votre candidature pour le stage de #{internship_application.internship_offer.title} a été acceptée. Vous pouvez maintenant la confirmer sur MonStageDeTroisieme : #{url}"

      client = OVH::REST.new(
        ENV['OVH_APPLICATION_KEY'],
        ENV['OVH_APPLICATION_SECRET'],
        ENV['OVH_CONSUMMER_KEY']
      )

      response = client.post("/sms/#{ENV['OVH_SMS_APPLICATION']}/jobs",
                             {
                               'sender': ENV['OVH_SENDER'],
                               'message': message,
                               'receivers': [phone],
                               'noStopClause': 'true'
                             })
      puts response
    end
  end
end