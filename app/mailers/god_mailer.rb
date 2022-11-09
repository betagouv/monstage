# frozen_string_literal: true

class GodMailer < ApplicationMailer
  require_relative '../libs/email_utils'

  default from: proc { EmailUtils.formatted_from }

  def weekly_kpis_email
    kpi_reporting_service = Reporting::Kpi.new
    @last_monday = kpi_reporting_service.send(:last_monday)
    @last_sunday = kpi_reporting_service.send(:last_sunday)
    @kpis = kpi_reporting_service.last_week_kpis
    @human_date        = I18n.l Date.today,   format: '%d %B %Y'
    @human_last_monday = I18n.l @last_monday, format: '%d %B %Y'
    @human_last_sunday = I18n.l @last_sunday, format: '%d %B %Y'

    mail(
      to: ENV['TEAM_EMAIL'],
      subject: "Monitoring monstagede3e : kpi du #{@human_date}"
    )
  end
end
