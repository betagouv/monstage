# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def anonymize_user(recipient_email:)
    mail(to: recipient_email, subject: 'Confirmation - suppression de votre compte')
  end

  def export_offers(recipient_email, params)
    offers = Finders::ReportingInternshipOffer.new(params: params).dimension_offer
    @department = params[:department].capitalize
    xlsx = render_to_string layout: false, handlers: [:axlsx], formats: [:xlsx], template: "reporting/internship_offers/index_offers", locals: { offers: offers, presenter_for_dimension: Presenters::Reporting::DimensionByOffer, department: @department }
    attachments["offres_#{params[:department].capitalize}.xlsx"] = {mime_type: Mime[:xlsx], content: xlsx}
    mail(to: recipient_email, subject: "Export des offres du département #{@department}")
  end
end