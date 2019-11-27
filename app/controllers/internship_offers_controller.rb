# frozen_string_literal: true

class InternshipOffersController < ApplicationController
  include Finders::InternshipOffers

  before_action :authenticate_user!, only: %i[create edit update destroy]
  after_action :increment_internship_offer_view_count, only: :show

  def index
    @internship_offers = query_internship_offers(warn_on_missing_school_weeks: true)
                          .order(id: :desc)
  end

  def show
    @internship_offer = InternshipOffer.find(params[:id])
    @previous_internship_offer = query_next_internship_offer(
      current: @internship_offer
    )
    @next_internship_offer = query_previous_internship_offer(
      current: @internship_offer
    )
    raise ActionController::RoutingError.new('Not Found') if @internship_offer.discarded?
    current_user_id = current_user.try(:id)
    if current_user
      @internship_application = @internship_offer.internship_applications
                                                 .where(user_id: current_user_id)
                                                 .first
    end
    @internship_application ||= @internship_offer.internship_applications
                                                 .build(user_id: current_user_id)
  end


  private
  def increment_internship_offer_view_count
    @internship_offer.increment!(:view_count) if current_user.is_a?(Users::Student)
  end
end
