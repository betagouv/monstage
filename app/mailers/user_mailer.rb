# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def anonymize_user(recipient_email:)
    mail(to: recipient_email, subject: 'Votre compte a bien été supprimée')
  end
end
