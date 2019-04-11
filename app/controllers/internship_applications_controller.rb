class InternshipApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_internship_offer, only: [:index, :update]

  def index
    set_intership_applications
    authorize! :read, @internship_offer
    authorize! :index, InternshipApplication
  end

  def create
    @internship_application = InternshipApplication.new(internship_application_params)
    authorize! :apply, InternshipOffer
    @internship_application.save!
    EmployerMailer.with(internship_application: @internship_application).new_internship_application_email.deliver_later
    redirect_to internship_offers_path, flash: { success: "Votre candidature a bien été envoyée." }
  rescue ActiveRecord::RecordInvalid => error
    @internship_offer = InternshipOffer.find(params[:internship_offer_id])
    flash[:danger] = "Erreur dans la saisie de votre candidature"
    render "internship_offers/show", status: :bad_request
  end

  private

  def valid_transition?
    %w[approve! reject! signed! cancel!].include?(params[:transition])
  end

  def set_intership_applications
    @internship_applications = @internship_offer.internship_applications
                                                .order(updated_at: :desc)
                                                .page(params[:page])
  end

  def find_internship_offer
    @internship_offer = InternshipOffer.find(params[:internship_offer_id])
  end

  def internship_application_params
    params.require(:internship_application).permit(:motivation, :internship_offer_week_id, :user_id)
  end
end
