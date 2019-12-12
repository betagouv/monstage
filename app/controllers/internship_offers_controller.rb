# frozen_string_literal: true

class InternshipOffersController < ApplicationController
  include Finders::InternshipOffers

  before_action :authenticate_user!, only: %i[create edit update destroy]

  before_action :set_internship_offer, only: %i[show]
  before_action :check_internship_offer_is_not_discarded_or_404, only: :show
  before_action :check_internship_offer_is_published_or_redirect, only: :show
  after_action :increment_internship_offer_view_count, only: :show

  def index
    @internship_offers = query_internship_offers(warn_on_missing_school_weeks: true)
                          .order(id: :desc)
  end

  def show
    @previous_internship_offer = query_next_internship_offer(
      current: @internship_offer
    )
    @next_internship_offer = query_previous_internship_offer(
      current: @internship_offer
    )


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
    @internship_offer = InternshipOffer.find(params[:id])
  end

  def check_internship_offer_is_not_discarded_or_404
    return unless @internship_offer.discarded?

    redirect_to(internship_offers_path, flash: { warning: "Cette offre a été supprimée et n'est donc plus accessible" })
  end

  def check_internship_offer_is_published_or_redirect
    return if can?(:create, @internship_offer)
    return if @internship_offer.published?

    redirect_to(internship_offers_path, flash: { warning: "Cette offre n'est plus disponible" })
  end

  def current_user_id
    current_user.try(:id)
  end

  def increment_internship_offer_view_count
    @internship_offer.increment!(:view_count) if current_user.is_a?(Users::Student)
  end
end
