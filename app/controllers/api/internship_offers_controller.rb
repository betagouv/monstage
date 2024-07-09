# frozen_string_literal: true

module Api
  class InternshipOffersController < ApiBaseController
    before_action :authenticate_api_user!

    def search
      render_not_authorized and return unless current_api_user.operator.api_full_access

      @internship_offers = finder.all.includes([:sector, :employer, :school]).order(id: :desc)
      
      formatted_internship_offers = format_internship_offers(@internship_offers)
      data = {
        pagination: page_links,
        internshipOffers: formatted_internship_offers,
      }
      render json: data, status: 200
    end

    def index
      @internship_offers = current_api_user.internship_offers.kept.order(id: :desc).page(params[:page])
      formatted_internship_offers = format_internship_offers(@internship_offers)
      data = {
        pagination: page_links,
        internshipOffers: formatted_internship_offers,
      }
      render json: data, status: 200
    end

    def create
      internship_offer_builder.create(params: create_internship_offer_params) do |on|
        on.success(&method(:render_created))
        on.failure(&method(:render_validation_error))
        on.duplicate(&method(:render_duplicate))
        on.argument_error(&method(:render_argument_error))
      end
    end

    def update
      internship_offer_builder.update(instance: InternshipOffer.find_by!(remote_id: params[:id]),
                                      params: update_internship_offer_params) do |on|
        on.success(&method(:render_ok))
        on.failure(&method(:render_validation_error))
        on.argument_error(&method(:render_argument_error))
      end
    end

    def destroy
      internship_offer_builder.discard(instance: InternshipOffer.find_by!(remote_id: params[:id])) do |on|
        on.success(&method(:render_ok))
        on.failure(&method(:render_discard_error))
      end
    end

    private

    def internship_offer_builder
      @builder ||= Builders::InternshipOfferBuilder.new(user: current_api_user,
                                                        context: :api)
    end

    def create_internship_offer_params
      params.require(:internship_offer)
            .permit(
              :title,
              :description,
              :employer_name,
              :employer_description,
              :employer_website,
              :street,
              :zipcode,
              :city,
              :remote_id,
              :permalink,
              :sector_uuid,
              :type,
              :max_candidates,
              :max_students_per_group,
              :is_public,
              :handicap_accessible,
              :lunch_break,
              daily_hours: {},
              coordinates: {},
              weeks: []
            )
    end

    def update_internship_offer_params
      params.require(:internship_offer)
            .permit(
              :title,
              :description,
              :employer_name,
              :employer_description,
              :employer_website,
              :street,
              :zipcode,
              :city,
              :permalink,
              :sector_uuid,
              :max_candidates,
              :max_students_per_group,
              :published_at,
              :is_public,
              :lunch_break,
              :handicap_accessible,
              daily_hours: {},
              coordinates: {},
              weeks: []
            )
    end

    def query_params
      params.permit(
        :page,
        :latitude,
        :longitude,
        :radius,
        :keyword,
        sector_ids: [],
        week_ids: []
      )
    end

    def finder
      @finder ||= Finders::InternshipOfferConsumer.new(
        params: query_params,
        user: current_api_user
      )
    end

    def format_internship_offers(internship_offers)
      internship_offers.map { |internship_offer|
        {
          id: internship_offer.id,
          title: internship_offer.title,
          description: internship_offer.description.to_s,
          employer_name: internship_offer.employer_name,
          url: internship_offer_url(internship_offer, query_params.merge({utm_source: current_api_user.operator.name})),
          city: internship_offer.city.capitalize,
          date_start: I18n.localize(internship_offer.first_date, format: :human_mm_dd_yyyy),
          date_end:  I18n.localize(internship_offer.last_date, format: :human_mm_dd_yyyy),
          latitude: internship_offer.coordinates.latitude,
          longitude: internship_offer.coordinates.longitude,
          image: view_context.asset_pack_url("media/images/sectors/#{internship_offer.sector.cover}"),
          sector: internship_offer.sector.name,
          handicap_accessible: internship_offer.handicap_accessible,
        }
      }
    end

    def page_links
      {
        totalInternshipOffers: @internship_offers.total_count,
        internshipOffersPerPage: InternshipOffer::PAGE_SIZE,
        totalPages: @internship_offers.total_pages,
        currentPage: @internship_offers.current_page,
        nextPage: @internship_offers.next_page ? search_api_internship_offers_url(query_params.merge({page: @internship_offers.next_page})) : nil,
        prevPage: @internship_offers.prev_page ? search_api_internship_offers_url(query_params.merge({page: @internship_offers.prev_page})) : nil,
        isFirstPage: @internship_offers.first_page?,
        isLastPage: @internship_offers.last_page?,
        pageUrlBase:  url_for(query_params.except('page'))
      }
    end
  end
end
