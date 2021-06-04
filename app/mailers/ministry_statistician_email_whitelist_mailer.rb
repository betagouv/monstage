# frozen_string_literal: true

class MinistryStatisticianEmailWhitelistMailer < ApplicationMailer
  def notify_ready(recipient_email:)
    @recipient_email = recipient_email
    mail(to: recipient_email,
         subject: 'Ouverture de votre accès référent central')
  end
end
