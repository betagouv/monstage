# frozen_string_literal: true

class CustomDeviseMailer < Devise::Mailer
  include Layoutable
  include Devise::Controllers::UrlHelpers


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
