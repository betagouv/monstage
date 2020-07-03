# frozen_string_literal: true

class SendSmsJob < ApplicationJob
  queue_as :default

  def perform(user)
    client = OVH::REST.new(
      Rails.application.credentials.ovh[:application_key],
      Rails.application.credentials.ovh[:application_secret],
      Rails.application.credentials.ovh[:consumer_key]
    )
    response = client.post("/sms/#{Rails.application.credentials.ovh[:sms_application]}/jobs", 
      { 
        'sender': Rails.application.credentials.ovh[:sender],
        'message': "Votre code de validation : #{user.phone_token}",
        'receivers': [user.formatted_phone]
      })
  end
end
