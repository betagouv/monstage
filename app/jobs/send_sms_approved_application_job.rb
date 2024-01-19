# frozen_string_literal: true

class SendSmsApprovedApplicationJob < ApplicationJob
  queue_as :default

  def perform(phone)
    content = "Votre candidature à un stage a été acceptée. Connectez-vous à" \
              " monstagedetroisieme.fr et contactez l'employeur pour " \
              "signer votre convention de stage."

    Services::SmsSender.new(phone_number: phone, content: content)
                       .perform
  end
end