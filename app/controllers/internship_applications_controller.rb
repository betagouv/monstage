class InternshipApplicationsController < ApplicationController

  def create
    @internship_application = InternshipApplication.create(internship_application_params)

    if @internship_application.valid?
      redirect_to internship_offers_path, flash: { success: "Votre candidature a bien été envoyée." }
    else
      @internship_offer = InternshipOffer.find(params[:internship_offer_id])
      redirect_to @internship_offer, flash: { danger: "Erreur dans la saisie de votre candidature" }
    end
  end

  private

  def internship_application_params
    params.require(:internship_application).permit(:motivation, :internship_offer_week_id, :user_id)
  end
end
