# frozen_string_literal: true

class SendSmsStudentValidatedApplicationJob < ApplicationJob
  queue_as :default

  def perform(internship_application_id: )
    internship_application = InternshipApplication.find(internship_application_id)
    url = internship_application.sgid_short_url
    phone = User.sanitize_mobile_phone_number(internship_application.student_phone, '+33')

    if phone.present?
      message = "Votre candidature pour le stage " \
                "de #{internship_application.internship_offer.title} " \
                "a été acceptée. Vous pouvez maintenant la confirmer " \
                "sur MonStageDeTroisieme : #{url}"

      client = OVH::REST.new(
        ENV['OVH_APPLICATION_KEY'],
        ENV['OVH_APPLICATION_SECRET'],
        ENV['OVH_CONSUMMER_KEY']
      )
      if ENV.fetch('NO_SMS', false)
        sms_message = "sms [internship_application_id = #{internship_application.id}] " \
                          "to be sent with message '#{message}' " \
                          "to phone number '#{phone}'"
        Rails.logger.info(sms_message)
        puts '================'
        puts "sms_message : #{sms_message}"
        puts '================'
        puts ''
      else
        response = client.post("/sms/#{ENV['OVH_SMS_APPLICATION']}/jobs",
                              {
                                'sender': ENV['OVH_SENDER'],
                                'message': message,
                                'receivers': [phone],
                                'noStopClause': 'true'
                              })
        puts response
      end
    else
      error_message = "sms [internship_application_id = #{internship_application.id}] " \
                      "to be sent with faulty phone " \
                      "number '#{internship_application.student_phone}'!"
      Rails.logger.error(error_message)
    end
  end
end