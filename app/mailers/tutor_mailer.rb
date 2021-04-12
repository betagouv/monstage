# frozen_string_literal: true

class TutorMailer < ApplicationMailer
  def new_tutor(tutor_id, internship_offer_id)
    @tutor = Users::Tutor.find(tutor_id)
    @internship_offer = InternshipOffer.find(internship_offer_id)
    @token = @tutor.store_reset_password_token

    mail(to: @tutor.email,
         subject: 'Vous avez été désigné tuteur de stage')
  end
end
