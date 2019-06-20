# frozen_string_literal: true

module Api

  class InternshipOffersController < ApiBaseController
    before_action :authenticate_api_user!

    def create
      internship_offer_builder.create(params: internship_offer_params) do |on|
        on.success do |created_internship_offer|
          render_success(status: :created, object: created_internship_offer)
        end
        on.duplicate do |failure_internship_offer|
          render_error(code: "DUPLICATE_INTERNSHIP_OFFER",
                       error: "an object with this remote_id already exists for this account",
                       status: :conflict)
        end
        on.failure do |failure_internship_offer|
          render_error(code: "CAN_NOT_CREATE_INTERNSHIP_OFFER",
                       error: failure_internship_offer.errors,
                       status: :bad_request)
        end
      end
    rescue ArgumentError,
           ActionController::ParameterMissing => error
     render_error(code: "BAD_PAYLOAD",
                  error: error.message,
                  status: :unprocessable_entity)
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
