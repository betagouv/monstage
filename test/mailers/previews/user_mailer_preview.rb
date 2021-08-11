class UserMailerPreview < ActionMailer::Preview
  def anonymize_user
    UserMailer.anonymize_user(recipient_email: 'hello@hoop.com')
  end

  def export_offers_when_ministry_statistician
    user = Users::MinistryStatistician.first
    UserMailer.export_offers(user, {})
  end
end
