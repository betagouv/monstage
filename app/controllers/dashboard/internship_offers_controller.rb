# frozen_string_literal: true

module Dashboard
  class InternshipOffersController < ApplicationController
    include InternshipOffersFinders

    before_action :authenticate_user!
    helper_method :order_direction

    def index
      @internship_offers = query_internship_offers.order(order_column => order_direction)
    end

    def show
      @internship_offer = InternshipOffer.find(params[:id])
    end

    def create
      internship_offer_builder.create(params: internship_offer_params) do |on|
        on.success do |created_internship_offer|
          redirect_to(dashboard_internship_offer_path(created_internship_offer),
                      flash: { success: 'Votre offre de stage est désormais en ligne, Vous pouvez à tout moment la supprimer ou la modifier. Nous vous remercions vivement pour votre participation à cette dynamique nationale.' })
        end
        on.failure do |failed_internship_offer|
          @internship_offer = failed_internship_offer || InternshipOffer.new
          find_selectable_weeks
          render :new, status: :bad_request
        end
      end
    rescue ActionController::ParameterMissing
      @internship_offer = InternshipOffer.new
      find_selectable_weeks
      render :new, status: :bad_request
    end

    def edit
      @internship_offer = InternshipOffer.find(params[:id])
      authorize! :update, @internship_offer
      find_selectable_weeks
    end

    def update
      internship_offer_builder.update(instance: InternshipOffer.find(params[:id]),
                                      params: internship_offer_params) do |on|
        on.success do |updated_internship_offer|
          redirect_to(updated_internship_offer,
                      flash: { success: 'Votre annonce a bien été modifiée' })
        end
        on.failure do |failed_internship_offer|
          @internship_offer = failed_internship_offer
          find_selectable_weeks
          render :edit, status: :bad_request
        end
      end
    rescue ActionController::ParameterMissing
      @internship_offer = InternshipOffer.find(params[:id])
      find_selectable_weeks
      render :edit, status: :bad_request
    end

    def destroy
      internship_offer_builder.discard(instance: InternshipOffer.find(params[:id])) do |on|
        on.success do
          redirect_to(dashboard_internship_offers_path,
                      flash: { success: 'Votre annonce a bien été supprimée' })
        end
        on.failure do |_failed_internship_offer|
          redirect_to(dashboard_internship_offers_path,
                      flash: { warning: "Votre annonce n'a pas été supprimée" })
        end
      end
    end

    def new
      authorize! :create, InternshipOffer
      if params[:duplicate_id].present?
        @internship_offer = current_user.internship_offers
                                        .find(params[:duplicate_id])
                                        .duplicate
      else
        @internship_offer = InternshipOffer.new
      end
      find_selectable_weeks
    end

    private

    VALID_ORDER_COLUMNS = %w[
      title
      view_count
      total_applications_count
      submitted_applications_count
      rejected_applications_count
      approved_applications_count
      convention_signed_applications_count
    ]

    def valid_order_column?
      VALID_ORDER_COLUMNS.include?(params[:order])
    end

    def order_column
      redirect_to(dashboard_internship_offers_path, flash: { danger: "Impossible de trier par #{params[:order]}" }) if params[:order] && !valid_order_column?
      return params[:order] if params[:order] && valid_order_column?
      :submitted_applications_count
    end

    def order_direction
      return params[:direction] if params[:direction] && %w[asc desc].include?(params[:direction])
      :desc
    end

    def internship_offer_builder
      @builder ||= Builders::InternshipOfferBuilder.new(user: current_user,
                                                        context: :web)
    end

    def internship_offer_params
      params.require(:internship_offer)
            .permit(:title, :description, :sector_id, :max_candidates,
                    :tutor_name, :tutor_phone, :tutor_email, :employer_website, :employer_name,
                    :street, :zipcode, :city, :department, :region, :academy,
                    :is_public, :group,
                    :employer_id, :employer_type, :school_id, :employer_description,
                    operator_ids: [], coordinates: {}, week_ids: [])
    end
  end
end
