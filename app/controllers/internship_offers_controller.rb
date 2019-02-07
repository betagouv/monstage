class InternshipOffersController < ApplicationController

  def index
    @internship_offers = InternshipOffer.all
  end
end
