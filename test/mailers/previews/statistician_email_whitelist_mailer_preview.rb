class StatisticianEmailWhitelistMailerPreview < ActionMailer::Preview
  def notify_ready
    statistician = Users::PrefectureStatistician.first
    StatisticianEmailWhitelistMailer.notify_ready(
      recipient_email: statistician.email
    )
  end
end
