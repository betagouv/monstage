class StatisticianEmailWhitelistMailerPreview < ActionMailer::Preview
  def notify_ready
    StatisticianEmailWhitelistMailer.notify_ready(recipient_email: 'hello@gmail.com')
  end
end
