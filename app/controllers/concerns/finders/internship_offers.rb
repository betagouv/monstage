# frozen_string_literal: true
module Finders
  module InternshipOffers
    extend ActiveSupport::Concern

    included do
      def current_user_or_visitor
        current_user || Users::Visitor.new
      end

      def query_internship_offers(warn_on_missing_school_weeks: false,
                                  available_in_the_future: true)
        flash_message_when_missing_school_weeks if warn_on_missing_school_weeks
        query = InternshipOffer.kept
                               .for_user(user: current_user_or_visitor,
                                         coordinates: coordinate_params)
                               .group(:id)
        query = query.available_in_the_future if available_in_the_future
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

      def flash_message_when_missing_school_weeks
        return unless current_user_or_visitor.missing_school_weeks?
        flash.now[:warning] = "Attention, votre établissement n'a pas encore renseigné ses dates de stages. Nous affichons des offres qui pourraient ne pas correspondre à vos dates."
      end
    end
  end
end
