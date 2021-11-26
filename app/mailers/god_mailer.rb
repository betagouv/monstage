# frozen_string_literal: true

class GodMailer < ApplicationMailer
  require_relative '../libs/email_utils'
  default from: proc { EmailUtils.formatted_email }

  def weekly_kpis_email
    current_week = Week.selectable_from_now_until_end_of_school_year.first
    last_week = Week.find(current_week.id.to_i - 2)
    @last_monday = last_week.week_date
    @last_sunday = @last_monday + 6.days
    @kpis = Reporting::Kpi.new.last_week_kpis(
      last_monday: @last_monday,
      last_sunday: @last_sunday
    )
    @human_date = Date.today.strftime('%d %B %Y')

    mail(
      to: ENV['KPI_ADMIN_EMAIL'],
      subject: "Monitoring monstagede3e : kpi du #{@human_date}"
    )
  end
end

