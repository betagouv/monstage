# frozen_string_literal: true

class PagesController < ApplicationController
  WEBINAR_URL = ENV.fetch('WEBINAR_URL').freeze
  layout 'homepage', only: %i[home
                              student_landing
                              pro_landing
                              school_management_landing
                              statistician_landing]

  def statistiques
    render 'pages/statistiques', layout: 'statistiques'
  end

  def register_to_webinar
    authorize! :subscribe_to_webinar, current_user
    current_user.update(subscribed_to_webinar_at: Time.zone.now)
    redirect_to WEBINAR_URL,
                allow_other_host: true
  end


  def flyer
    respond_to do |format|
      format.html
      format.pdf do
        send_data(
          File.read(Rails.root.join("public", "MS3_Flyer_2022.pdf")),
          filename: "MS3E_flyer_2022.pdf",
          type: 'application/pdf',
          disposition: 'inline'
        )
      end
    end
  end

  def offers_with_sector
    InternshipOffer.includes([:sector])
  end

  def student_landing
    @internship_offers = offers_with_sector.last(3)
  end
  alias_method :school_management_landing, :student_landing
  alias_method :statistician_landing, :student_landing
end
