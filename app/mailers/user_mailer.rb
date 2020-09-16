# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def anonymize_user(recipient_email:)
    mail(to: recipient_email, subject: 'Votre compte a bien été supprimé')
  end

  def update_email_instructions(record, token, opts = {})
    mail(to: record.email, subject: 'Kikoo bonjour')
  end

  def add_email_instructions(record, token, opts = {})
    mail(to: record.email, subject: 'Kikoo rebonjour')
  end

end
