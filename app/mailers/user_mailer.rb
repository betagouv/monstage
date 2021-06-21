# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def anonymize_user(recipient_email:)
    mail(to: recipient_email, subject: 'Confirmation - suppression de votre compte')
  end

  def export_offers(user, params)
    recipient_email = user.email
    params.merge!(group: user.ministry_id) if user.ministry_statistician?
    presenter = UserManager.new.presenter(user)
    offers = Finders::ReportingInternshipOffer.new(params: params).dimension_offer
    @department = params[:department]&.capitalize # might be nil
    attachment_name = "offres_#{@department}#{presenter&.ministry_filename}.xlsx"
    xlsx = render_to_string layout: false,
                            handlers: [:axlsx],
                            formats: [:xlsx],
                            template: "reporting/internship_offers/index_offers",
                            locals: { offers: offers,
                                      presenter_for_dimension: Presenters::Reporting::DimensionByOffer,
                                      department: @department }
    attachments[attachment_name] = {mime_type: Mime[:xlsx], content: xlsx}
    subject = presenter.offer_export_mail_subject(department: @department)
    mail(to: recipient_email, subject: subject)
  end
end
