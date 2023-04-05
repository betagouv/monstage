# frozen_string_literal: true

class InternshipOffersController < ApplicationController
  before_action :authenticate_user!, only: %i[create edit update destroy]
  layout 'search', only: :index

  with_options only: [:show] do
    before_action :set_internship_offer,
                  :check_internship_offer_is_not_discarded_or_redirect,
                  :check_internship_offer_is_published_or_redirect

    after_action :increment_internship_offer_view_count
  end

  def index

    respond_to do |format|
      format.html do
        # @internship_offers = finder.all.order(id: :desc)
        # @formatted_internship_offers = format_internship_offers(@internship_offers)
        # @alternative_internship_offers = alternative_internship_offers if @internship_offers.to_a.count == 0
        @sectors = Sector.all.order(:name).to_a
        @params = query_params
      end
      format.json do
        # puts 'in controller'
        # puts params
        @internship_offers_all_without_page = finder.all_without_page
        @internship_offers = finder.all.includes([:sector]).order(id: :desc)
        # puts '@internship_offers'
        # puts @internship_offers.to_a.count
        # puts InternshipOffer.all.to_a.count

        @is_suggestion = @internship_offers.to_a.count === 0
        # puts '@is_suggestion'
        @internship_offers = alternative_internship_offers if @internship_offers.to_a.count == 0
        # puts '@internship_offers after alternative'

        formatted_internship_offers = format_internship_offers(@internship_offers)
        # puts 'formatted_internship_offers'
        @params = query_params
        # puts '@params'
        # p formatted_internship_offers
        # puts 'formatted_internship_offers'
        # puts calculate_seats
        # puts 'calculate_seats'
        # puts page_links
        # puts 'pages_links'
        data = {
          internshipOffers: formatted_internship_offers,
          pageLinks: page_links,
          seats: calculate_seats,
          isSuggestion: @is_suggestion
        }
        render json: data, status: 200
      end
    end
  end

  def show
    check_internship_offer_is_published_or_redirect
    @previous_internship_offer = finder.next_from(from: @internship_offer)
    @next_internship_offer = finder.previous_from(from: @internship_offer)

    if current_user
      @internship_application = @internship_offer.internship_applications
                                                 .where(user_id: current_user_id)
                                                 .first
    end
    @internship_application ||= @internship_offer.internship_applications
                                                 .build(user_id: current_user_id)
  end

  private

  def set_internship_offer
    @internship_offer = InternshipOffer.with_rich_text_description_rich_text
                                       .with_rich_text_employer_description_rich_text
                                       .find(params[:id])
  end

  def query_params
    params.permit(
      :page,
      :latitude,
      :longitude,
      :city,
      :radius,
      :keyword,
      week_ids: []
    )
  end

  def check_internship_offer_is_not_discarded_or_redirect
    return unless @internship_offer.discarded?

    redirect_to(
      user_presenter.default_internship_offers_path,
      flash: {
        warning: "Cette offre a été supprimée et n'est donc plus accessible"
      }
    )
  end

  def check_internship_offer_is_published_or_redirect
    return if can?(:create, @internship_offer)
    return if @internship_offer.published?

    redirect_to(
      user_presenter.default_internship_offers_path,
      flash: { warning: "Cette offre n'est plus disponible" }
    )
  end

  def current_user_id
    current_user.try(:id)
  end

  def finder
    @finder ||= Finders::InternshipOfferConsumer.new(
      params: params.permit(
        :page,
        :latitude,
        :longitude,
        :radius,
        :keyword,
        sector_ids: [],
        week_ids: []
      ),
      user: current_user_or_visitor
    )
    @finder
  end

  def alternative_internship_offers
    priorities = [
      [:week_ids], #1
      [:latitude, :longitude, :radius], #2
      [:keyword] #3
    ]

    alternative_internship_offers = []
    priorities.each do |priority|
      next unless priority.any? { |p| params[p].present? && params[p] != Nearbyable::DEFAULT_NEARBY_RADIUS_IN_METER.to_s }

      alternative_internship_offers << Finders::InternshipOfferConsumer.new(
        params: params.permit(*priority),
        user: current_user_or_visitor
      ).all.to_a

      alternative_internship_offers = alternative_internship_offers.flatten
      break if alternative_internship_offers.count > 5
      alternative_internship_offers
    end
    alternative_internship_offers.first(5)
  end

  def increment_internship_offer_view_count
    @internship_offer.increment!(:view_count) if current_user&.student?
  end

  def format_internship_offers(internship_offers)
    internship_offers.map { |internship_offer|
      {
        id: internship_offer.id,
        title: internship_offer.title.truncate(35),
        description: internship_offer.description.to_s,
        employer_name: internship_offer.employer_name,
        link: internship_offer_path(internship_offer, query_params),
        city: internship_offer.city.capitalize,
        date_start: I18n.localize(internship_offer.first_date, format: :human_mm_dd_yyyy),
        date_end:  I18n.localize(internship_offer.last_date, format: :human_mm_dd_yyyy),
        lat: internship_offer.coordinates.latitude,
        lon: internship_offer.coordinates.longitude,
        image: view_context.asset_pack_path("media/images/sectors/#{internship_offer.sector.cover}"),
        sector: internship_offer.sector.name,
        is_favorite: current_user ? current_user.favorites.pluck(:internship_offer_id).include?(internship_offer.id) : false,
        logged_in: !!current_user
      }
    }
  end

  def page_links    
    return nil if @internship_offers.size < 1 || @is_suggestion
    {
      totalPages: @internship_offers.total_pages,
      currentPage: @internship_offers.current_page,
      nextPage: @internship_offers.next_page,
      prevPage: @internship_offers.prev_page,
      isFirstPage: @internship_offers.first_page?,
      isLastPage: @internship_offers.last_page?,
      pageUrlBase:  url_for(query_params.except('page'))
    }
  end

  def calculate_seats
    @internship_offers_all_without_page.pluck(:max_candidates).sum
  end
end
