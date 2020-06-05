# frozen_string_literal: true

class SendSmsJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    user.create_phone_token
    client = Ovh::Client.new
    client.post("/sms/#{ENV['OVH_SMS_SERVICE']}/jobs", 
      params: { 
        'sender': 'MonStagede3e',
        'message': "Votre code de validation : #{user.phone_token}",
        receivers: [recipient]
      })
  end
end
