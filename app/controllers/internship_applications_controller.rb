class InternshipApplicationsController < ApplicationController

  def create
    @internship_application = InternshipApplication.create(internship_application_params)

    if @internship_application.valid?
      EmployerMailer.with(internship_application: @internship_application).new_internship_application_email.deliver_later
      redirect_to internship_offers_path, flash: { success: "Votre candidature a bien été envoyée." }
    else
      @internship_offer = InternshipOffer.find(params[:internship_offer_id])
      redirect_to @internship_offer, flash: { danger: "Erreur dans la saisie de votre candidature" }
    end
  end

  def update
    @internship_application = InternshipApplication.find(params[:id])
    authorize! :update, @internship_application
    if params[:approve] == 'true'
      @internship_application.approve!
    else
      @internship_application.reject!
    end

    redirect_to @internship_application.internship_offer, flash: { success: 'Candidature mis à jour avec succès' }
  end

  private

  def internship_application_params
    params.require(:internship_application).permit(:motivation, :internship_offer_week_id, :user_id)
  end
end
