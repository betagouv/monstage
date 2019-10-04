# frozen_string_literal: true

module InternshipOffersFinders
  extend ActiveSupport::Concern

  included do
    def current_user_or_visitor
      current_user || Users::Visitor.new
    end

    def query_internship_offers
      query = InternshipOffer.kept
                             .available_in_the_future
                             .for_user(user: current_user_or_visitor,
                                       coordinates: coordinate_params)
      query = query.merge(InternshipOffer.by_sector(params[:sector_id])) if params[:sector_id]
      query = query.page(params[:page]) # force kaminari interface no matter presence of page param
      query
    end

    def query_next_internship_offer(current:)
      query_internship_offers
        .order(id: :desc)
        .next_from(current: current, column: :id, order: :desc)
        .limit(1)
        .first
    end

    def query_previous_internship_offer(current:)
       query_internship_offers
        .order(id: :desc)
        .previous_from(current: current, column: :id, order: :desc)
        .limit(1)
        .first
    end

    def coordinate_params
      coordinates = params.permit(:latitude, :longitude)
      return nil unless params.key?(:latitude) || params.key?(:longitude)
      geo_point_factory(latitude: params[:latitude], longitude: params[:longitude])
    end
  end
end
