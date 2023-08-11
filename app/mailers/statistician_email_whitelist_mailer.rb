# frozen_string_literal: true

class StatisticianEmailWhitelistMailer < ApplicationMailer
  def notify_ready(recipient_email:)
    @recipient_email = recipient_email
    @user_class = EmailWhitelist.where(email: recipient_email).first.class.to_s.split('::').last
    send_email(
      to: recipient_email,
      subject: 'Ouverture de votre accès référent départemental'
    )
  end
end
