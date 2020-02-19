# frozen_string_literal: true

class AnonymizeUserJob < ApplicationJob
  queue_as :default

  def perform(email)
    UserMailer.anonymize_user(recipient_email: email).deliver_now
  end
end
