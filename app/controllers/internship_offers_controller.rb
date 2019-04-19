class InternshipOffersController < ApplicationController
  include SetInternshipOffers

  before_action :authenticate_user!, only: [:index, :create, :edit, :update, :destroy]

  def index
    set_internship_offers
    @internship_offers = @internship_offers.merge(InternshipOffer.by_sector(params[:sector_id])) if params[:sector_id]
  end

  def show
    @internship_offer = InternshipOffer.find(params[:id])
    @internship_application = InternshipApplication.find_or_initialize_by(user_id: current_user.id) if user_signed_in?
  end
end
