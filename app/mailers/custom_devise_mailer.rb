# frozen_string_literal: true

class CustomDeviseMailer < Devise::Mailer
  include Layoutable
  include Devise::Controllers::UrlHelpers

  def update_email_instructions(record, token, opts = {})
    @resource = record
    mail(to: record.email, subject: 'Kikoo bonjour')
  end

  def add_email_instructions(record, token, opts = {})
    @resource = record
    mail(to: record.email, subject: 'Kikoo rebonjour')
  end
end
