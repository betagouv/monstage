class InternshipOffersController < ApplicationController
  include SetInternshipOffers

  before_action :authenticate_user!, only: [:index, :create, :edit, :update, :destroy]

  def index
    set_internship_offers
    @internship_offers = @internship_offers.merge(InternshipOffer.by_sector(params[:sector_id])) if params[:sector_id]
  end

  def show
    @internship_offer = InternshipOffer.find(params[:id])
    current_user_id = current_user.try(:id)
    @internship_application = @internship_offer.internship_applications
                                               .where(user_id: current_user_id)
                                               .first if current_user
    @internship_application ||= @internship_offer.internship_applications
                                                 .build(user_id: current_user_id)
  end
end
