# frozen_string_literal: true

class StatisticianMailer < ApplicationMailer
  def notify_ready(statistician)
    @statistician = statistician
    @url = new_user_session_url

    send_email(
      to: @statistician.email,
      subject: "Ouverture de votre accès #{ t(@statistician.role, scope: 'activerecord.attributes.user.roles') }"
    )
  end
end
