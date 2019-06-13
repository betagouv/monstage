# frozen_string_literal: true

module Api
  class InternshipOffersController < ApiBaseController
    include SetInternshipOffers

    before_action :authenticate_api_user!

    def create
    end

    def destroy
    end

    private

    def internship_offer_params
      params.require(:internship_offer)
            .permit(
              :title, # : Titre de l’offre de stage
              :description, # : Description de l'offre de stage
              :employer_name, # : Nom de l’entreprise proposant le stage
              :employer_description, # : Description de l’entreprise proposant le stage
              :employer_website, # : Lien web vers le site de l’entreprise proposant le stage
              :coordinates, # : { latitude: 1, longitude: 1 } ; coordonnées géographique du lieu de stage
              :street, # : Nom de la rue ou se déroule le stage
              :zipcode, #  : Code postal du lieu de stage
              :city, # : Nom de la ville où se déroule le stage
              :sector_uuid, # : voir référentiel
              :weeks # : voir référentiel.
            )
    end
  end
end
