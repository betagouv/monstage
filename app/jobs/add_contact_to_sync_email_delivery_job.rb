# frozen_string_literal: true

class AddContactToSyncEmailDeliveryJob < ActiveJob::Base
  queue_as :default

  discard_on ActiveJob::DeserializationError

  def perform(user:)
    Services::SyncEmailDelivery.new.create_contact(user: user)
  end
end
