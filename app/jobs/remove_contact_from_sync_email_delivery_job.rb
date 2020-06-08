class RemoveContactFromSyncEmailDeliveryJob < ActiveJob::Base
  queue_as :default

  # TO BE DISCUSSED
  retry_on ActiveRecord::Deadlocked, wait: 5.seconds, attempts: 3
  retry_on Timeout::Error, wait: 5.seconds, attempts: 3
  retry_on Errno::EINVAL, wait: 5.seconds, attempts: 3
  retry_on EOFError, wait: 5.seconds, attempts: 3
  retry_on Errno::ECONNRESET, wait: 5.seconds, attempts: 3
  retry_on Net::HTTPBadResponse, wait: 5.seconds, attempts: 3
  retry_on Net::HTTPHeaderSyntaxError, wait: 5.seconds, attempts: 3
  retry_on Net::HTTPClientError, wait: 5.seconds, attempts: 3

  discard_on ActiveJob::DeserializationError

  def perform(email:)
    Services::SyncEmailDelivery.new.delete_contact(email: email)
  end
end

