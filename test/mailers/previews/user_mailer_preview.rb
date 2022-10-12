class UserMailerPreview < ActionMailer::Preview
  def anonymize_user
    UserMailer.anonymize_user(recipient_email: 'hello@hoop.com')
  end

end
