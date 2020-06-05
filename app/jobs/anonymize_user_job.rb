# frozen_string_literal: true

class AnonymizeUserJob < ApplicationJob
  queue_as :default

  def perform(email)
    UserMailer.anonymize_user(recipient_email: email).deliver_now

    # Sendgrid to withdraw this email from the mailing lists
    email_delivery = Services::EmailDelivery.new
    email_delivery.contact_delete(email: email)
  end
end
