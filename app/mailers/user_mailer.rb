# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def anonymize_user(recipient_email:)
    mail(to: recipient_email, subject: 'Confirmation - suppression de votre compte')
  end

  def export_offers(recipient_email, params)
    offers = Finders::ReportingInternshipOffer.new(params: params).dimension_offer
    xlsx = render_to_string layout: false, handlers: [:axlsx], formats: [:xlsx], template: "reporting/internship_offers/index_offers", locals: { offers: offers, presenter_for_dimension: Presenters::Reporting::DimensionByOffer }
    attachments["offers.xlsx"] = {mime_type: Mime[:xlsx], content: xlsx}
    mail(to: "maxime.pierrot@gmail.com", subject: 'Export Offres')
  end
end