# frozen_string_literal: true

class EmailWhitelistMailer < ApplicationMailer
  def notify_ready(recipient_email:)
    mail(to: recipient_email,
         subject: "Votre accès référent départemental")
  end
end
