# frozen_string_literal: true

module Dashboard
  class InternshipOffersController < ApplicationController
    before_action :authenticate_user!
    before_action :set_internship_offer,
                  only: %i[edit update destroy republish remove]

    helper_method :order_direction

    def index
      if current_user.employer_like?
        @internship_offer_areas = current_user.internship_offer_areas
      end
      authorize! :index, Acl::InternshipOfferDashboard.new(user: current_user)
      @internship_offers = finder.all.includes([:internship_offer_weeks])
      order_param = order_direction.nil? ? :published_at : {order_column => order_direction}
      @internship_offers = @internship_offers.order(order_param)
      if params[:search].present?
        @internship_offers = @internship_offers.where(
          "title ILIKE :search OR employer_name ILIKE :search OR city ILIKE :search",
          search: "%#{params[:search]}%"
        )
      end
    end

    # duplicate submit
    def create
      authorize! :create, InternshipOffer
      internship_offer_builder.create(params: internship_offer_params) do |on|
        on.success do |created_internship_offer|
          success_message = if params[:commit] == 'Renouveler l\'offre'
                              'Votre offre de stage a été renouvelée pour cette année scolaire.'
                            else
                              "L'offre de stage a été dupliquée en tenant compte" \
                              ' de vos éventuelles modifications.'
                            end
          redirect_to(internship_offer_path(created_internship_offer, stepper: true),
                      flash: { success: success_message })
        end
        on.failure do |failed_internship_offer|
          @internship_offer = failed_internship_offer || InternshipOffer.new
          @available_weeks = Week.selectable_from_now_until_end_of_school_year
          render :new, status: :bad_request
        end
      end
    rescue ActionController::ParameterMissing
      @internship_offer = InternshipOffer.new
      @available_weeks = Week.selectable_from_now_until_end_of_school_year
      render :new, status: :bad_request
    end

    def edit
      authorize! :update, @internship_offer
      @republish = true
      @available_weeks = Week.selectable_from_now_until_end_of_school_year
    end

    def republish
      anchor = "max_candidates_fields"
      warning = "Votre annonce n'est pas encore republiée, car il faut ajouter des places et des semaines de stage"

      if @internship_offer.remaining_seats_count.zero? && @internship_offer.has_weeks_in_the_future?
        warning = "Votre annonce n'est pas encore republiée, car il faut ajouter des places de stage"
      elsif (@internship_offer.remaining_seats_count > 0) && !@internship_offer.has_weeks_in_the_future?
        anchor = "weeks_container"
        warning = "Votre annonce n'est pas encore republiée, car il faut ajouter des semaines de stage"
      end
      redirect_to edit_dashboard_internship_offer_path(@internship_offer, anchor: anchor),
                  flash: { warning: warning}
    end

    def update
      authorize! :update, @internship_offer
      internship_offer_builder.update(instance: @internship_offer,
                                      params: internship_offer_params) do |on|

      on.success do |updated_internship_offer|
        @internship_offer = updated_internship_offer
        respond_to do |format|
          format.turbo_stream
          format.html do
            redirect_to dashboard_internship_offers_path(origine: 'dashboard'),
                        flash: { success: 'Votre annonce a bien été modifiée' }
          end
        end
      end
      on.failure do |failed_internship_offer|
        respond_to do |format|
          format.html do
            @internship_offer = failed_internship_offer
            @available_weeks = failed_internship_offer.available_weeks_when_editing
            render :edit, status: :bad_request
          end
        end
      end
      rescue ActionController::ParameterMissing
        respond_to do |format|
          format.html do
            @available_weeks = @internship_offer.available_weeks_when_editing
            render :edit, status: :bad_request
          end
        end
      end
    end

    def destroy
      internship_offer_builder.discard(instance: @internship_offer) do |on|
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

    def publish
      @internship_offer = InternshipOffer.find(params[:id])
      authorize! :publish, @internship_offer
      if @internship_offer.requires_updates?
        republish
      else
        @internship_offer.publish!
        redirect_to dashboard_internship_offers_path(origine: 'dashboard'),
                    flash: { success: 'Votre annonce a bien été publiée' }
      end
    end

    def remove # Back to step 4
      if offer_contains_stepper_informations?
        redirect_to(
          edit_dashboard_stepper_practical_info_path(
            id: @internship_offer.practical_info_id,
            organisation_id: @internship_offer.organisation_id,
            internship_offer_info_id: @internship_offer.internship_offer_info_id,
            hosting_info_id: @internship_offer.hosting_info_id
          )
        )
      else
        redirect_to( edit_dashboard_internship_offer_path( id: @internship_offer.id ) )
      end
    end

    # duplicate form
    def new
      authorize! :create, InternshipOffer
      internship_offer = current_user.internship_offers.find(params[:duplicate_id]).duplicate

      if params[:without_location].present?
        @internship_offer = internship_offer.duplicate_without_location
      else
        @internship_offer = internship_offer.duplicate
      end

      @available_weeks = Week.selectable_from_now_until_next_school_year
    end

    private

    VALID_ORDER_COLUMNS = %w[
      title
      approved_applications_count
      remaining_seats_count
    ].freeze

    def valid_order_column?
      VALID_ORDER_COLUMNS.include?(params[:order])
    end

    def offer_contains_stepper_informations?
      !!(@internship_offer.practical_info_id &&
        @internship_offer.hosting_info_id &&
        @internship_offer.internship_offer_info_id &&
        @internship_offer.organisation_id)
    end


    def finder
      @finder ||= Finders::InternshipOfferPublisher.new(
        params: params.permit(
          :page,
          :latitude,
          :longitude,
          :radius,
          :school_type,
          :keyword,
          :school_year,
          :filter
        ),
        user: current_user_or_visitor
      )
    end

    def order_column
      if params[:order] && !valid_order_column?
        redirect_to(dashboard_internship_offers_path,
                    flash: { danger: "Impossible de trier par #{params[:order]}" })
      end
      return params[:order] if params[:order] && valid_order_column?

      :submitted_applications_count
    end

    def order_direction
      return nil unless params[:direction]

      return params[:direction] if %w[asc desc].include?(params[:direction])
    end

    def internship_offer_builder
      @builder ||= Builders::InternshipOfferBuilder.new(user: current_user,
                                                        context: :web)
    end

    def internship_offer_params
      params.require(:internship_offer)
            .permit(:title, :description_rich_text, :sector_id, :max_candidates,
                    :max_students_per_group, :tutor_name, :tutor_phone, :tutor_role,
                    :tutor_email, :employer_website, :employer_name, :street,
                    :zipcode, :city, :department, :region, :academy, :renewed,
                    :is_public, :group_id, :published_at, :republish, :type,
                    :employer_id, :employer_type, :school_id, :verb, :user_update,
                    :employer_description_rich_text, :siret, :employer_manual_enter,
                    :contact_phone, :lunch_break, :aasm_state, coordinates: {}, week_ids: [],
                    daily_hours: {}, weekly_hours:[],
                    organisation_attributes: [
                      :id,
                      :employer_name,
                      :street,
                      :zipcode,
                      :city,
                      :siret,
                      :manual_enter,
                      :employer_description_rich_text,
                      :employer_website,
                      :is_public,
                      :group_id,
                      :autocomplete,
                      coordinates: {}
                    ])
    end

    def set_internship_offer
      @internship_offer = InternshipOffer.find(params[:id])
    end
  end
end
