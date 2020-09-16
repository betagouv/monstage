# frozen_string_literal: true

class CustomDeviseMailer < Devise::Mailer
  include Layoutable
  include Devise::Controllers::UrlHelpers

  def update_email_instructions(record, token, opts = {})
    @resource = record
    @token = token
    mail(to: record.email, subject: "Action requise - Confirmez votre changement d'adresse électronique (e-mail)")
  end

  def add_email_instructions(user)
    @resource = user
    @token = token
    mail(to: user.unconfirmed_email, subject: 'Action requise - Confirmez votre nouvelle adresse électronique (e-mail)')
  end
end
