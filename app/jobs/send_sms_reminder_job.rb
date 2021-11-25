# frozen_string_literal: true

class SendSmsReminderJob < ApplicationJob
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
                             'message': "Votre code de validation : #{user.phone_token}",
                             'receivers': phone
                           })
  end
end