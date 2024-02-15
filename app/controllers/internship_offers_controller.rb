# frozen_string_literal: true

class InternshipOffersController < ApplicationController
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
        @sectors = Sector.all.order(:name).to_a
        @params = query_params
      end
      format.json do
        @internship_offers_all_without_page = finder.all_without_page
        @internship_offers = finder.all

        @is_suggestion = @internship_offers.to_a.count.zero?
        @internship_offers = alternative_internship_offers if @is_suggestion

        @internship_offers_all_without_page_array = @internship_offers_all_without_page.to_a
        @internship_offers_array = @internship_offers.to_a

        formatted_internship_offers = format_internship_offers(@internship_offers)
        @params = query_params
        data = {
          internshipOffers: formatted_internship_offers,
          pageLinks: page_links,
          seats: calculate_seats,
          isSuggestion: @is_suggestion
        }
        current_user.log_search_history(@params.merge({results_count: data[:seats]})) if current_user&.student?
        render json: data, status: 200
      end
    end
  end

  def show

    @previous_internship_offer = finder.next_from(from: @internship_offer)
    @next_internship_offer = finder.previous_from(from: @internship_offer)

    if current_user
      @internship_application = @internship_offer.internship_applications
                                                 .where(user_id: current_user_id)
                                                 .first
      @internship_offer.log_view(current_user)
    end
    @internship_application ||= @internship_offer.internship_applications
                                                 .build(user_id: current_user_id)
  end

  def apply_count
    @internship_offer = InternshipOffer.find(params[:id])
    @internship_offer.log_apply(current_user)
  end

  private

  def set_internship_offer
    @internship_offer = InternshipOffer.find(params[:id])
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
    from_email = [params[:origin], params[:origine]].include?('email')
    authenticate_user! if current_user.nil? && from_email
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
  end

  def alternative_internship_offers
    # TODO refacto : difficult to understand
    priorities = [
      [:latitude, :longitude, :radius], #1
      [:week_ids], #2
      [:keyword] #3
    ]

    alternative_internship_offers = []
    priorities.each do |priority|
      next unless priority.any? { |p| params[p].present? && params[p] != Nearbyable::DEFAULT_NEARBY_RADIUS_IN_METER.to_s }

      priority_offers = Finders::InternshipOfferConsumer.new(
        params: params.permit(*priority),
        user: current_user_or_visitor
      ).all.to_a

      if priority_offers.count < 5 && priority == [:latitude, :longitude, :radius]
        priority_offers = Finders::InternshipOfferConsumer.new(
          params: params.permit(*priority).merge(radius: Nearbyable::DEFAULT_NEARBY_RADIUS_IN_METER + 40_000),
          user: current_user_or_visitor
        ).all.to_a
      end

      alternative_internship_offers << priority_offers

      alternative_internship_offers = alternative_internship_offers.flatten
      break if alternative_internship_offers.count > 5
      alternative_internship_offers
    end

    if params[:latitude].present?
      alternative_internship_offers.sort_by { |offer| offer.distance_from(params[:latitude], params[:longitude]) }.first(5)
    else
      alternative_internship_offers.first(5)
    end
  end

  def increment_internship_offer_view_count
    @internship_offer.stats.increment!(:view_count) if current_user&.student?
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
        is_favorite: !!current_user && internship_offer.is_favorite?(current_user),
        logged_in: !!current_user,
        can_manage_favorite: can?(:create, Favorite)
      }
    }
  end

  def page_links
    offers = @internship_offers
    return nil if offers.to_a.size < 1 || @is_suggestion
    {
      totalPages: offers.total_pages,
      currentPage: offers.current_page,
      nextPage: offers.next_page,
      prevPage: offers.prev_page,
      isFirstPage: offers.first_page?,
      isLastPage: offers.last_page?,
      pageUrlBase:  url_for(query_params.except('page'))
    }
  end

  def calculate_seats
    @internship_offers_all_without_page.pluck(:max_candidates).sum
  end
end
