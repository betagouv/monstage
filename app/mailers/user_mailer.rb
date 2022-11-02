# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def anonymize_user(recipient_email:)
    mail(to: recipient_email, subject: 'Confirmation - suppression de votre compte')
  end

  def export_offers(user, params)
    recipient_email = user.email
    params.merge!(groups: user.ministries.map(&:id)) if user.ministry_statistician?
    offers = Finders::ReportingInternshipOffer.new(params: params).dimension_offer

    attachment_name = "#{serialize_params_for_filenaming(params)}.xlsx"
    xlsx = render_to_string layout: false,
                            handlers: [:axlsx],
                            formats: [:xlsx],
                            template: "reporting/internship_offers/index_offers",
                            locals: { offers: offers,
                                      presenter_for_dimension: Presenters::Reporting::DimensionByOffer }
    attachments[attachment_name] = {mime_type: Mime[:xlsx], content: xlsx}
    mail(to: recipient_email, subject: "Export des offres de monstagedetroisieme")
  end

  private

  def serialize_params_for_filenaming(params)
    params.inject("export-des-offres-") do |accu, (k,v)|
      "#{accu}-#{k.to_s.parameterize}-#{v.to_s.parameterize}"
    end
  end

end
