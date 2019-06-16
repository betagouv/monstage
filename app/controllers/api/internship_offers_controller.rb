# frozen_string_literal: true

module Api

  class InternshipOffersController < ApiBaseController
    before_action :authenticate_api_user!

    def create
      internship_offer_builder.create(params: internship_offer_params) do |on|
        on.success do |created_internship_offer|
          render status: :created,
                 jsonapi: created_internship_offer
          end
        on.failure do |failure_internship_offer|
          render status: :bad_request,
                 jsonapi_errors: failure_internship_offer.errors
        end
      end
    rescue ArgumentError,
           ActionController::ParameterMissing => error
      render status: :unprocessable_entity,
             jsonapi_errors: [SerializableError.new(error.message)]
    end

    def destroy
    end

    private

    def internship_offer_builder
      @builder ||= Builders::InternshipOfferBuilder.new(user: current_api_user,
                                                        context: :api)
    end

    def internship_offer_params
      params.require(:internship_offer)
            .permit(
              :title, # : Titre de l’offre de stage
              :description, # : Description de l'offre de stage
              :employer_name, # : Nom de l’entreprise proposant le stage
              :employer_description, # : Description de l’entreprise proposant le stage
              :employer_website, # : Lien web vers le site de l’entreprise proposant le stage
              :street, # : Nom de la rue ou se déroule le stage
              :zipcode, #  : Code postal du lieu de stage
              :city, # : Nom de la ville où se déroule le stage
              :remote_id,
              :permalink,
              :sector_uuid, # : voir référentiel
              coordinates: {}, # : { latitude: 1, longitude: 1 } ; coordonnées géographique du lieu de stage
              weeks: [], # : voir référentiel,

            )
    end
  end
end
