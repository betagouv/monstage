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

  def send_email(to:, subject:, cc: nil)
    @site_url = site_url
    if to.blank?
      Rails.logger.error("mail without recipient sending attempt. Subject: #{subject}")
    elsif email_array_bypass?(to: to)
      Rails.logger.info("mail bypassed. Subject: #{subject}")
    else
      params = { to: to, subject: subject }
      params.merge!(cc: cc) unless cc.nil?
      mail(params)
    end
  end

  private

  def email_array_bypass?(to:)
    if to.is_a?(Array)
      to.any? { |email| email_bypass?(to: email) }
    else
      email_bypass?(to: to)
    end
  end

  def email_bypass?(to:)
    recipient = User.kept.find_by(email: to)
    return false if recipient.nil? # as for transfers
    return false unless recipient.employer_like?

    recipient.fetch_current_area_notification&.notify
  end
end
