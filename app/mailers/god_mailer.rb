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

  def weekly_pending_applications_email
    internship_applications = InternshipApplication.submitted.where('submitted_at > :date', date: 30.days.ago).where(canceled_at: nil)

    @human_date = I18n.l Date.today,   format: '%d %B %Y'

    attachment_name = "export_candidatures_non_repondues.xlsx"
    xlsx = render_to_string layout: false,
                            handlers: [:axlsx],
                            formats: [:xlsx],
                            template: "reporting/internship_applications/pending_internship_applications",
                            locals: { internship_applications: internship_applications,
                                      presenter_for_dimension: Presenters::Reporting::DimensionByOffer }
    attachments[attachment_name] = {mime_type: Mime[:xlsx], content: xlsx}

    mail(
      to: ENV['TEAM_EMAIL'],
      subject: "Monitoring monstagede3e : Candidatures non répondues au #{@human_date}"
    )
  end

  def weekly_expired_applications_email
    internship_applications = InternshipApplication.expired.where('expired_at > :date', date: 15.days.ago)

    @human_date = I18n.l Date.today,   format: '%d %B %Y'

    attachment_name = "export_candidatures_expirees_depuis_15_jours.xlsx"
    xlsx = render_to_string layout: false,
                            handlers: [:axlsx],
                            formats: [:xlsx],
                            template: "reporting/internship_applications/expired",
                            locals: { internship_applications: internship_applications,
                                      presenter_for_dimension: Presenters::Reporting::DimensionByOffer }
    attachments[attachment_name] = {mime_type: Mime[:xlsx], content: xlsx}

    mail(
      to: ENV['TEAM_EMAIL'],
      subject: "Monitoring monstagede3e : Candidatures expirées depuis 15 jours au #{@human_date}"
    )
  end
end
