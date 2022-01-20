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

    attr_accessor :params # since school_track can be an implicit filter
    attr_reader :user, :listable_query_builder

    def initialize(user:, params:)
      @user = user
      @params = params
      @listable_query_builder = Finders::ListableInternshipOffer.new(finder: self)
    end

    def keyword_params
      return nil unless params.key?(:keyword)
      return nil if params.dig(:keyword).blank?

      params[:keyword]
    end

    def coordinate_params
      return nil unless params.key?(:latitude) || params.key?(:longitude)
      return nil if params.dig(:latitude).blank? || params.dig(:longitude).blank?

      geo_point_factory(latitude: params[:latitude], longitude: params[:longitude])
    end

    def radius_params
      return Nearbyable::DEFAULT_NEARBY_RADIUS_IN_METER unless params.key?(:radius)

      params[:radius]
    end

    def school_track_params
      return nil unless params.key?(:school_track)
      return nil if params.dig(:school_track).blank?

      params[:school_track]
    end

    def school_year_param
      return nil unless params.key?(:school_year)
      return nil if params.dig(:school_year).blank?

      params[:school_year].to_i
    end

    def week_ids_params
      return nil unless params.key?(:week_ids)
      return nil if params.dig(:week_ids).blank?

      params[:week_ids]
    end

    def common_filter
      query = yield

      query = keyword_query(query) if keyword_params
      query = nearby_query(query) if coordinate_params
      query = school_track_query(query) if school_track_params
      query = school_year_query(query) if school_year_param
      query = week_ids_query(query) if week_ids_params
      query
    end


    def week_ids_query(query)
      query.merge(weekly_framed_scopes(:by_weeks, weeks: OpenStruct.new(ids: week_ids_params)))
    end

    def school_year_query(query)
      query.merge(weekly_framed_scopes(:specific_school_year, school_year: school_year_param))
    end

    def keyword_query(query)
      query.merge(InternshipOffer.search_by_keyword(params[:keyword]).group(:rank))
    end

    def nearby_query(query)
      query.merge(
        query.nearby(latitude: coordinate_params.latitude,
                     longitude: coordinate_params.longitude,
                     radius: radius_params)
             .with_distance_from(latitude: coordinate_params.latitude,
                                 longitude: coordinate_params.longitude)
      )
    end

    def school_track_query(query)
      query = query.merge(InternshipOffer.school_track(school_track: params[:school_track]))

      if params[:school_track] == 'troisieme_generale'
        query = query.merge(
          weekly_framed_scopes(:ignore_already_applied, {user: user})
        )
        query = query.merge(
          weekly_framed_scopes(:ignore_max_candidates_reached)
        )
        query = query.merge(
          weekly_framed_scopes(:ignore_max_internship_offer_weeks_reached)
        )
      else
        query = query.merge(InternshipOffers::FreeDate.ignore_already_applied(user: user))
      end
      query
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
