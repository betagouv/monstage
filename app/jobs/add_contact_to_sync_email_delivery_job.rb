# frozen_string_literal: true

class AddContactToSyncEmailDeliveryJob < ActiveJob::Base
  queue_as :default

  discard_on ActiveJob::DeserializationError

  def perform(user:)
    sync_delivery_service = Services::SyncEmailDelivery.new
    sync_delivery_service.create_contact(user: user) unless sync_delivery_service.contact_exists?(email: user.email)
    sync_delivery_service.update_contact_metadata(user: user)
  end
end
