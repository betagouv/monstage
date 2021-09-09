# frozen_string_literal: true

class InternshipOffersController < ApplicationController
  before_action :authenticate_user!, only: %i[create edit update destroy]

  with_options only: [:show] do
    before_action :set_internship_offer,
                  :check_internship_offer_is_not_discarded_or_redirect,
                  :check_internship_offer_is_published_or_redirect

    after_action :increment_internship_offer_view_count
  end

  def index
    @internship_offers = finder.all.order(id: :desc)
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
                                                 .build(user_id: current_user_id,
                                                        type: current_user.try(:internship_applications_type))
  end

  private

  def set_internship_offer
    @internship_offer = InternshipOffer.with_rich_text_description_rich_text
                                       .with_rich_text_employer_description_rich_text
                                       .find(params[:id])
  end

  def check_internship_offer_is_not_discarded_or_redirect
    return unless @internship_offer.discarded?

    redirect_to(user_presenter.default_internship_offers_path, flash: { warning: "Cette offre a été supprimée et n'est donc plus accessible" })
  end

  def check_internship_offer_is_published_or_redirect
    return if can?(:create, @internship_offer)
    return if @internship_offer.published?

    redirect_to(user_presenter.default_internship_offers_path, flash: { warning: "Cette offre n'est plus disponible" })
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
        :school_track
      ),
      user: current_user_or_visitor
    )
  end

  def increment_internship_offer_view_count
    @internship_offer.increment!(:view_count) if current_user&.student?
  end
end
