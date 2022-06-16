# frozen_string_literal: true

module Dashboard
  class InternshipOffersController < ApplicationController
    before_action :authenticate_user!
    helper_method :order_direction

    def index
      authorize! :index,
                 Acl::InternshipOfferDashboard.new(user: current_user)
      @internship_offers = finder.all
      @internship_offers = @internship_offers.merge(filter_scope)
      @internship_offers = @internship_offers.order(order_column => order_direction)
    end

    # duplicate submit
    def create
      internship_offer_builder.create(params: internship_offer_params) do |on|
        on.success do |created_internship_offer|
          success_message = if params[:commit] == 'Renouveler l\'offre'
                              'Votre offre de stage a été renouvelée pour cette année scolaire.'
                            else
                              "L'offre de stage a été dupliquée en tenant compte" \
                              ' de vos éventuelles modifications.'
                            end
          redirect_to(internship_offer_path(created_internship_offer),
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
      @internship_offer = InternshipOffer.find(params[:id])
      authorize! :update, @internship_offer
      @available_weeks = @internship_offer.available_weeks
    end

    def update
      internship_offer_builder.update(instance: InternshipOffer.find(params[:id]),
                                      params: internship_offer_params) do |on|

      on.success do |updated_internship_offer|
        @internship_offer = updated_internship_offer
        respond_to do |format|
          format.turbo_stream
          format.html do
            redirect_to(internship_offer_path(updated_internship_offer),
                        flash: { success: 'Votre annonce a bien été modifiée' })
          end
        end
      end
      on.failure do |failed_internship_offer|
        respond_to do |format|
          format.html do
            @internship_offer = failed_internship_offer
            @available_weeks = failed_internship_offer.available_weeks
            render :edit, status: :bad_request
          end
        end
      end
      rescue ActionController::ParameterMissing
        respond_to do |format|
          format.html do
            @internship_offer = InternshipOffer.find(params[:id])
            @available_weeks = @internship_offer.available_weeks
            render :edit, status: :bad_request
          end
        end
      end
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

    # duplicate form
    def new
      authorize! :create, InternshipOffer
      internship_offer = current_user.internship_offers.find(params[:duplicate_id]).duplicate

      if params[:without_location].present?
        @internship_offer = internship_offer.duplicate_without_location
      else
        @internship_offer = internship_offer.duplicate
      end

      @available_weeks = Week.selectable_from_now_until_end_of_school_year
    end

    private

    VALID_ORDER_COLUMNS = %w[
      title
      view_count
      rejected_applications_count
      approved_applications_count
      submitted_applications_count
      convention_signed_applications_count
      total_applications_count
    ].freeze

    def valid_order_column?
      VALID_ORDER_COLUMNS.include?(params[:order])
    end

    def filter_scope
      case params[:filter]
      when 'unpublished'                 then InternshipOffer.unpublished
      when 'past'                        then InternshipOffer.in_the_past
      else InternshipOffer.published.in_the_future
      end
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
      return params[:direction] if params[:direction] && %w[asc
                                                            desc].include?(params[:direction])

      :desc
    end

    def internship_offer_builder
      @builder ||= Builders::InternshipOfferBuilder.new(user: current_user,
                                                        context: :web)
    end

    def internship_offer_params
      params.require(:internship_offer)
            .permit(:title, :description_rich_text, :sector_id, :max_candidates,
                    :max_students_per_group, :tutor_name, :tutor_phone,
                    :tutor_email, :employer_website, :employer_name, :street,
                    :zipcode, :city, :department, :region, :academy, :renewed,
                    :is_public, :group_id, :published_at, :type,
                    :employer_id, :employer_type, :school_id, :verb,
                    :employer_description_rich_text, :siret, :employer_manual_enter,
                    :weekly_lunch_break, coordinates: {}, week_ids: [],
                    new_daily_hours: {}, daily_lunch_break: {}, weekly_hours:[])
    end
  end
end
