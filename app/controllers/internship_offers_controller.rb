# frozen_string_literal: true

class InternshipOffersController < ApplicationController
  include SetInternshipOffers

  before_action :authenticate_user!, only: %i[index create edit update destroy]
  after_action :increment_internship_offer_view_count, only: :show

  def index
    set_internship_offers
    @internship_offers = @internship_offers.merge(InternshipOffer.by_sector(params[:sector_id])) if params[:sector_id]
  end

  def show
    @internship_offer = InternshipOffer.find(params[:id])
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
