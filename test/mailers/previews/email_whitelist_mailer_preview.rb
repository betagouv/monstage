class EmailWhitelistMailerPreview < ActionMailer::Preview
  def notify_ready
    EmailWhitelistMailer.notify_ready(recipient_email: 'hello@gmail.com')
  end
end
