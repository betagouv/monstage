# frozen_string_literal: true

class FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_internship_offer, only: [:create, :destroy]

  def create
    favorite = Favorite.where(user_id: current_user.id, internship_offer_id: @internship_offer.id)&.first
    favorite ||= Favorite.new(internship_offer: @internship_offer, user: current_user)
    if favorite.save
      render json: format_internship_offer(@internship_offer), status: 200
    else
      render(json: "Erreur #{favorite.errors.messages}", status: 500)
    end
  end

  def destroy
    Favorite.where(internship_offer_id: @internship_offer.id, user_id: current_user.id)
            .try(:first)
            .try(:destroy)
    render json: format_internship_offer(@internship_offer), status: 200
  end

  def index
    @internship_offers = format_internship_offers(current_user.internship_offers)
  end

  private

  def set_internship_offer
    @internship_offer ||= InternshipOffer.find(params[:internship_offer_id] || params[:id])
  end

  def format_internship_offers(internship_offers)
    internship_offers.map { |internship_offer| format_internship_offer(internship_offer) }
  end

  def format_internship_offer(internship_offer)
    {
      id: internship_offer.id,
      title: internship_offer.title.truncate(35),
      description: internship_offer.description.to_s,
      employer_name: internship_offer.employer_name,
      link: internship_offer_path(internship_offer),
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
  end
end
