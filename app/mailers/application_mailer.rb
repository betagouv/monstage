# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  require_relative '../libs/email_utils'
  default from: proc { EmailUtils.formatted_from }
  default reply_to: proc { EmailUtils.formatted_reply_to }

  require_relative './concerns/layoutable'
  include Layoutable

  append_view_path 'app/views/mailers'

  def send_email(to:, subject:, cc: nil)
    return if to.nil?

    params = { to: to, subject: subject }
    params.merge!(cc: cc) unless cc.nil?
    mail(params)
  end
end
