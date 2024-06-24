# frozen_string_literal: true

class CustomDeviseMailer < Devise::Mailer
  require_relative '../libs/email_utils'
  default from: proc { EmailUtils.formatted_from }
  default reply_to: proc { EmailUtils.formatted_reply_to }

  include Layoutable
  include Devise::Controllers::UrlHelpers

  def update_email_instructions(record, token, opts = {})
    @resource = record
    @token = token
    mail(to: record.unconfirmed_email, subject: "Confirmez votre changement d'adresse électronique")
  end

  def add_email_instructions(user)
    @resource = user
    @token = user.confirmation_token
    mail(to: user.unconfirmed_email, subject: 'Confirmez votre nouvelle adresse électronique')
  end
end
