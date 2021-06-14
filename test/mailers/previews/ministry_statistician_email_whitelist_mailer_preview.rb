class MinistryStatisticianEmailWhitelistMailerPreview < ActionMailer::Preview
  def notify_ready
    ministry_statistician = Users::MinistryStatistician.first
    if ministry_statistician.nil?
      Rails.logger.error('missing ministry statistician')
      raise ArgumentError , 'missing ministry statistician'
    end
    MinistryStatisticianEmailWhitelistMailer.notify_ready(
      recipient_email: ministry_statistician.email
    )
  end
end
