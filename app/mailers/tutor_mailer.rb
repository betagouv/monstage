# frozen_string_literal: true

class TutorMailer < ApplicationMailer
  def new_tutor(tutor_id, internship_offer_id)
    @internship_offer = InternshipOffer.find(internship_offer_id)
    tutor = Users::Tutor.find(tutor_id)
    @registered_tutor = tutor.encrypted_password.present?
    token = tutor.store_reset_password_token
    @link_url = if @registered_tutor
      dashboard_internship_offers_url
    else
      edit_invited_password_url(reset_password_token: token)
    end

    mail(to: tutor.email, subject: 'Vous avez été désigné tuteur de stage')
  end
end
