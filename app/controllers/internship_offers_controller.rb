class InternshipOffersController < ApplicationController
  before_action :authenticate_user!, only: [:index, :create, :edit, :update, :destroy]

  def index
    query = InternshipOffer.kept
                           .for_user(user: current_user)
                           .page(params[:page])
    query = query.merge(InternshipOffer.filter_by_sector(params[:sector_id])) if params[:sector_id]
    @internship_offers = query
    template = case current_user.class.name
               when Users::Employer.name then "employer_index"
               else "index"
               end
    render template
  end

  def show
    @internship_offer = InternshipOffer.find(params[:id])
    @internship_application = InternshipApplication.new(user_id: current_user.id) if user_signed_in?
  end

  def create
    authorize! :create, InternshipOffer
    @internship_offer = InternshipOffer.new(internship_offer_params)
    @internship_offer.save!
    redirect_to(internship_offer_path(@internship_offer),
                flash: {success: 'Votre offre de stage est désormais en ligne, Vous pouvez à tout moment la supprimer ou la modifier. Nous vous remercions vivement pour votre participation à cette dynamique nationale.'})
  rescue ActiveRecord::RecordInvalid,
         ActionController::ParameterMissing
    @internship_offer ||= InternshipOffer.new
    find_selectable_content
    render 'internship_offers/new', status: :bad_request
  end

  def edit
    @internship_offer = InternshipOffer.find(params[:id])
    authorize! :update, @internship_offer
    find_selectable_content
  end

  def update
    @internship_offer = InternshipOffer.find(params[:id])
    authorize! :update, @internship_offer
    @internship_offer.update!(internship_offer_params)
    redirect_to(@internship_offer,
                flash: { success: 'Votre annonce a bien été modifiée'})
  rescue ActiveRecord::RecordInvalid,
         ActionController::ParameterMissing => error
    find_selectable_content
    render :edit, status: :bad_request
  end

  def destroy
    @internship_offer = InternshipOffer.find(params[:id])
    authorize! :destroy, @internship_offer
    @internship_offer.discard
    redirect_to(internship_offer_path,
                flash: { success: 'Votre annonce a bien été supprimée' })
  end

  def new
    authorize! :create, InternshipOffer
    @internship_offer = InternshipOffer.new
    find_selectable_content
  end

  private

  def find_selectable_content
    find_selectable_weeks
  end

  def internship_offer_params
    params.require(:internship_offer)
        .permit(:title, :description, :sector_id, :max_candidates, :max_internship_week_number,
                :tutor_name, :tutor_phone, :tutor_email, :employer_website, :employer_name,
                :employer_street, :employer_zipcode, :employer_city, :is_public, :group_name,
                :employer_id, :school_id, :employer_description,
                operator_names: [], coordinates: {}, week_ids: [])
  end
end
