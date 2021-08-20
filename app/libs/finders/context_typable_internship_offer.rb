# frozen_string_literal: true

module Finders
  # build base query to request internship offers per user.type
  class ContextTypableInternshipOffer
    delegate :next_from,
             :previous_from,
             :all,
             to: :listable_query_builder

    def base_query
      send(mapping_user_type.fetch(user.type))
        .group(:id)
        .page(params[:page])
    end

    private

    attr_reader :user, :params, :listable_query_builder

    def initialize(user:, params:)
      @user = user
      @params = params
      @listable_query_builder = Finders::ListableInternshipOffer.new(finder: self)
    end

    def nearby_query_part(query, coordinates)
      query.nearby(latitude: coordinates.latitude,
                   longitude: coordinates.longitude,
                   radius: radius_params)
           .with_distance_from(latitude: coordinates.latitude,
                               longitude: coordinates.longitude)
    end

    def keyword_params
      return nil unless params.key?(:keyword)

      params[:keyword]
    end

    def coordinate_params
      return nil unless params.key?(:latitude) || params.key?(:longitude)

      geo_point_factory(latitude: params[:latitude], longitude: params[:longitude])
    end

    def radius_params
      return Nearbyable::DEFAULT_NEARBY_RADIUS_IN_METER unless params.key?(:radius)

      params[:radius]
    end

    def school_track_params
      return nil unless params.key?(:school_track)

      params[:school_track]
    end

    def school_year_param
      return nil unless params.key?(:school_year)

      params[:school_year].to_i
    end

    def common_filter
      query = yield

      query = keyword_query(query) if keyword_params
      query = nearby_query(query) if coordinate_params
      query = school_track_query(query) if school_track_params
      query = school_year_query(query) if school_year_param
      query
    end

    def school_year_query(query)
      query.merge(weekly_framed_scopes(:specific_school_year, school_year: school_year_param))
    end

    def keyword_query(query)
      query.merge(InternshipOffer.search_by_keyword(params[:keyword]).group(:rank))
    end

    def nearby_query(query)
      query.merge(nearby_query_part(query, coordinate_params))
    end

    def school_track_query(query)
      query.merge(InternshipOffer.school_track(school_track: school_track_params))
    end

    protected

    def weekly_framed_scopes(scope, args = nil)
      if args.nil?
        InternshipOffers::WeeklyFramed.send(scope)
          .or(InternshipOffers::Api.send(scope))
      else
        InternshipOffers::WeeklyFramed.send(scope, args)
          .or(InternshipOffers::Api.send(scope, args))
      end
    end
  end
end
