module Dashboard
  class InternshipOffersController < ApplicationController
    include SetInternshipOffers

    before_action :authenticate_user!

    def index
      set_internship_offers
      @internship_offers = @internship_offers.order(total_applications_count: :desc,
                                                    updated_at: :desc)
    end

    def show
      @internship_offer = InternshipOffer.find(params[:id])
    end

    def create
      authorize! :create, InternshipOffer
      @internship_offer = InternshipOffer.new(internship_offer_params)
      @internship_offer.save!
      redirect_to(dashboard_internship_offer_path(@internship_offer),
                  flash: {success: 'Votre offre de stage est désormais en ligne, Vous pouvez à tout moment la supprimer ou la modifier. Nous vous remercions vivement pour votre participation à cette dynamique nationale.'})
    rescue ActiveRecord::RecordInvalid,
           ActionController::ParameterMissing
      @internship_offer ||= InternshipOffer.new
      find_selectable_content
      render :new, status: :bad_request
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
      redirect_to(dashboard_internship_offers_path,
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
                  :street, :zipcode, :city, :department, :region, :academy,
                  :is_public, :group_name,
                  :employer_id, :employer_type, :school_id, :employer_description,
                  operator_ids: [], coordinates: {}, week_ids: [])
    end
  end
end
