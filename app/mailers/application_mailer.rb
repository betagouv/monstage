# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  require_relative '../libs/email_utils'
  default from: proc { EmailUtils.formatted_from }
  default reply_to: proc { EmailUtils.formatted_reply_to }

  require_relative './concerns/layoutable'
  include Layoutable

  append_view_path 'app/views/mailers'

  def site_url
    @site_url ||= root_url.html_safe
  end

  def send_email(to:, subject:, cc: nil, specific_layout: nil)
    Rails.logger.error("mail without recipient sending attempt. " \
                       "Subject: #{subject}") and return if to.blank?
    
    params = { to: to, subject: subject }
    params.merge!(cc: cc) unless cc.nil?
    mail(**params) and return if specific_layout.nil?

    mail(**params) do |format|
      format.html { render layout: specific_layout }
      format.text
    end
  end
end
