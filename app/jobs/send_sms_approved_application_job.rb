# frozen_string_literal: true

class SendSmsApprovedApplicationJob < ApplicationJob
  queue_as :default

  def perform(phone)

    client = OVH::REST.new(
      ENV['OVH_APPLICATION_KEY'],
      ENV['OVH_APPLICATION_SECRET'],
      ENV['OVH_CONSUMMER_KEY']
    )
    response = client.post("/sms/#{ENV['OVH_SMS_APPLICATION']}/jobs",
                {
                  'sender': ENV['OVH_SENDER'],
                  'message': "Votre candidature à un stage a été acceptée. Connectez-vous à monstagedetroisieme.fr et contactez l'employeur pour signer votre convention de stage.",
                  'receivers': [phone],
                  'noStopClause': 'true'
                })
  end
end