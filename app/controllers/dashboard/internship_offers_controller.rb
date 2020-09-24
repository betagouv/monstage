# frozen_string_literal: true

module Dashboard
  class InternshipOffersController < ApplicationController
    before_action :authenticate_user!
    helper_method :order_direction

    def index
      authorize! :index, Acl::InternshipOfferDashboard.new(user: current_user)

      @internship_offers   = finder.all
      @internship_offers   = @internship_offers.merge(filter_scope)
      @internship_offers   = @internship_offers.order(order_column => order_direction)

      @all_states_counters = all_states_counters
    end

    def create
      internship_offer_builder.create(params: internship_offer_params) do |on|
        on.success do |created_internship_offer|
          # Mentor.create() TO DO
          redirect_to(internship_offer_path(created_internship_offer),
                      flash: { success: 'Votre offre de stage est désormais en ligne, Vous pouvez à tout moment la supprimer ou la modifier.' })
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
      @available_weeks = Week.selectable_on_school_year
    end

    def update
      @internship_offer = InternshipOffer.find(params[:id])
      authorize! :update, @internship_offer

      internship_offer_builder.update(instance: @internship_offer,
                                      params: internship_offer_params) do |on|
        on.success do |updated_internship_offer|
          redirect_to(internship_offer_path(updated_internship_offer),
                      flash: { success: 'Votre annonce a bien été modifiée' })
        end
        on.failure do |failed_internship_offer|
          @internship_offer = failed_internship_offer
          @available_weeks = Week.selectable_on_school_year
          render :edit, status: :bad_request
        end
      end
    rescue ActionController::ParameterMissing
      @internship_offer = InternshipOffer.find(params[:id])
      @available_weeks = Week.selectable_on_school_year
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
      @internship_offer = if params[:duplicate_id].present?
                            current_user.internship_offers
                                        .find(params[:duplicate_id])
                                        .duplicate
                          else
                            InternshipOffer.new
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
      when 'approved_applications_count' then InternshipOffer.in_the_future.to_be_signed
      else InternshipOffer.published.in_the_future
      end
    end

    def all_states_counters
      filtered_offers = finder.all
      { to_be_signed: filtered_offers.in_the_future.to_be_signed.to_a.count }
    end

    def finder
      @finder ||= Finders::ListableInternshipOffer.new(
        params: params.permit(
          :page,
          :latitude,
          :longitude,
          :radius,
          :school_type,
          :keyword
        ),
        user: current_user_or_visitor
      )
    end

    def order_column
      if params[:order] && !valid_order_column?
        redirect_to(dashboard_internship_offers_path, flash: { danger: "Impossible de trier par #{params[:order]}" })
      end
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

    def internship_params(type)
      params.require(type.to_sym)
            .permit(:title, :description_rich_text, :sector_id, :max_candidates,
                    :tutor_name, :tutor_phone, :tutor_email, :employer_website, :employer_name,
                    :street, :zipcode, :city, :department, :region, :academy,
                    :is_public, :group_id, :published_at, :type, :description,
                    :employer_id, :employer_type, :school_id, :employer_description_rich_text,
                    :school_type, :school_track, :internship_offer_info_id, :organisation_id, coordinates: {}, week_ids: [])
    end

    def internship_offer_params
      case params
      when -> (h) { h[:internship_offers_free_date].present? }
        internship_params('internship_offers_free_date')
      when -> (h) { h[:internship_offers_weekly_framed].present? }
        internship_params('internship_offers_weekly_framed')
      when -> (h) { h[:internship_offers].present? }
        internship_params('internship_offers')
      else
        internship_params('internship_offer')
      end
    end

  end
end
