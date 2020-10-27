# frozen_string_literal: true

class RemoveContactFromSyncEmailDeliveryJob < ActiveJob::Base
  queue_as :default

  def perform(email:)
    Services::SyncEmailDelivery.new.destroy_contact(email: email)
  end
end
