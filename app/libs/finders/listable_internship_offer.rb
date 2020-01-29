# frozen_string_literal: true
module Finders
  class ListableInternshipOffer
    def all
      base_query
    end

    def next_from(from:)
      base_query.order(id: :desc)
                .next_from(current: from, column: :id, order: :desc)
                .limit(1)
                .first
    end

    def previous_from(from:)
       base_query.order(id: :desc)
                 .previous_from(current: from, column: :id, order: :desc)
                 .limit(1)
                 .first
    end

    private
    attr_reader :params, :user

    def initialize(params:, user:)
      @params = params
      @user = user
    end

    def base_query
      query = InternshipOffer.kept
                             .available_in_the_future
                             .for_user(user: user,
                                       coordinates: coordinate_params)
                             .group(:id)
      query = query.page(params[:page]) # force kaminari interface no matter presence of page param
      query
    end

    def coordinate_params
      return nil unless params.key?(:latitude) || params.key?(:longitude)
      geo_point_factory(latitude: params[:latitude], longitude: params[:longitude])
    end
  end
end
