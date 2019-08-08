# frozen_string_literal: true

module SetInternshipOffers
  extend ActiveSupport::Concern

  included do
    def set_internship_offers
      @internship_offers = InternshipOffer.kept
                                          .available_in_the_future
                                          .for_user(user: current_user, coordinates: coordinate_params)
                                          .page(params[:page])
    end

    def coordinate_params
      coordinates = params.permit(:latitude, :longitude)
      return nil unless params.key?(:latitude) || params.key?(:longitude)
      geo_point_factory(latitude: params[:latitude], longitude: params[:longitude])
    end
  end
end
