class InternshipOffersController < ApplicationController
  before_action :authenticate_user!, only: [:index, :create, :edit, :update, :destroy]

  def index
    query = InternshipOffer.kept
                           .for_user(user: current_user)
                           .page(params[:page])
    query = query.merge(InternshipOffer.filter_by_sector(params[:sector_id])) if params[:sector_id]
    @internship_offers = query
  end

  def show
    @internship_offer = InternshipOffer.find(params[:id])
    @internship_application = InternshipApplication.new(user_id: current_user.id) if user_signed_in?
  end
end
