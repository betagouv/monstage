# frozen_string_literal: true

class CustomDeviseMailer < Devise::Mailer
  include Layoutable
  include Devise::Controllers::UrlHelpers

  def confirmation_instructions(record, token, _opts = {})
    if creating_account?
      super(record, token, opts = {})
    elsif updating_email?

    elsif adding_email?
    else
      raise 'wtf?'
    end
  end

  private
  # user.attributes['unconfirmed_email'] : next email
  # user.attributes['email'] : current email (may be nil for user registred by sms)
  def creating_account?
  end

  def updating_email?

  end

  def adding_email?
  end
end
