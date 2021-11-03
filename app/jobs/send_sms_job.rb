# frozen_string_literal: true

class SendSmsJob < ApplicationJob
  queue_as :default

  discard_on ActiveJob::DeserializationError
  retry_on OVH::RESTError, wait: 5.seconds, attempts: 4
  retry_on Net::OpenTimeout, Timeout::Error, wait: 5.seconds, attempts: 4
  # resolves https://sentry.io/organizations/brice-durand/issues/2169771890/?project=1393439&query=is%3Aunresolved

  def perform(user)
    client = OVH::REST.new(
      ENV['OVH_APPLICATION_KEY'],
      ENV['OVH_APPLICATION_SECRET'],
      ENV['OVH_CONSUMMER_KEY']
    )
    response = client.post("/sms/#{ENV['OVH_SMS_APPLICATION']}/jobs",
                           {
                             'sender': ENV['OVH_SENDER'],
                             'message': "Votre code de validation : #{user.phone_token}",
                             'receivers': [user.formatted_phone]
                           })
  end
end
