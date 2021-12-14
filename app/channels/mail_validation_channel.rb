# frozen_string_literal: true

class MailValidationChannel < ApplicationCable::Channel
  def subscribed
    stream_from params['uid']
  end

  def validate(params)
    email = params['email']
    uid = params['uid']
    role = params['role']

    email_inquire = EmailInquire.validate(email)
    email = email_inquire.email
    status = email_inquire.status
    replacement = email_inquire.replacement

    if email_inquire.valid? && role == 'school_manager'
      status = :invalid unless Academy::MAP_EMAIL_DOMAIN.map{ |k,v| v }.include?(email_inquire.email.split('@').last)
    end

    ActionCable.server.broadcast(uid, {
                                   email: email,
                                   status: status,
                                   replacement: replacement
                                 })
  end
end
