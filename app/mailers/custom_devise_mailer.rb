# frozen_string_literal: true

class CustomDeviseMailer < Devise::Mailer
  include Layoutable
  include Devise::Controllers::UrlHelpers

  def confirmation_instructions(record, token, _opts = {})
    if creating_account?(record)
      super(record, token, opts = {})
    elsif updating_email?(record)
      return UserMailer.update_email_instructions(record, token, opts = {})
    elsif adding_email?(record)
    else
      raise 'wtf?'
    end
  end

  protected



  private
  # user.attributes['unconfirmed_email'] : next email
  # user.attributes['email'] : current email (may be nil for user registred by sms)
  def creating_account?(record)
    record.confirmed_at.nil?
  end
  
  def updating_email?(record)
    record.confirmed_at.present? && record.email.present?
  end

  def adding_email?(record)

  end

end
