# frozen_string_literal: true

module Finders
  # build base query to request internship offers per user.type
  class UserTypableInternshipOffer
    MappingUserTypeWithScope = {
      Users::SchoolManagement.name => :school_members_query,
      Users::Student.name =>          :school_members_query,
      Users::Employer.name =>         :employer_query,
      Users::Operator.name =>         :operator_query,
      Users::Statistician.name =>     :statistician_query,
      Users::Visitor.name =>          :visitor_query,
      Users::God.name =>              :god_query
    }.freeze

    def base_query
      send(MappingUserTypeWithScope.fetch(user.type))
        .group(:id)
        .page(params[:page])
    end

    private

    attr_reader :user, :params

    def initialize(user:, params:)
      @user = user
      @params = params
    end

    def nearby_query_part(query, coordinates)
      query.nearby(latitude: coordinates.latitude,
                   longitude: coordinates.longitude,
                   radius: radius_params)
           .with_distance_from(latitude: coordinates.latitude,
                               longitude: coordinates.longitude)
    end

    def school_members_query
      query = keywords_and_coordinates_query do

        InternshipOffers::WeeklyFramed.kept
                                      .in_the_future
                                      .published
                                      .ignore_internship_restricted_to_other_schools(school_id: user.school_id)
                                      .ignore_max_candidates_reached
                                      .ignore_max_internship_offer_weeks_reached
      end

      if !user.missing_school_weeks? && user.school
        query = query.merge(query.internship_offers_overlaping_school_weeks(weeks: user.school.weeks))
      end

      if user.try(:middle_school?)
        query = query.merge(InternshipOffers::WeeklyFramed.ignore_already_applied(user: user))
      # elsif user.try(:high_school?)
        # query = query.merge(InternshipOffers::FreeDate.ignore_already_applied(user: user))
      end

      query
    end

    def employer_query
      keywords_and_coordinates_query do
        user.internship_offers.kept
      end
    end

    def operator_query
      query = keywords_and_coordinates_query do
        InternshipOffer.kept.submitted_by_operator(user: user)
      end
      if user.department_name.present?
        query = query.merge(query.limited_to_department(user: user))
      end
      query
    end

    def statistician_query
      query = keywords_and_coordinates_query do
        InternshipOffer.kept
      end
      if user.department_name
        query = query.merge(query.limited_to_department(user: user))
      end
      query
    end

    def visitor_query
      keywords_and_coordinates_query do
        InternshipOffer.kept.in_the_future.published
      end
    end

    def god_query
      keywords_and_coordinates_query do
        InternshipOffer.kept
      end
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
      unless params.key?(:radius)
        return Nearbyable::DEFAULT_NEARBY_RADIUS_IN_METER
      end

      params[:radius]
    end

    def keywords_and_coordinates_query
      query = yield
      if keyword_params
        query = query.merge(InternshipOffer.search_by_keyword(params[:keyword]).group(:rank))
      end
      if coordinate_params
        query = query.merge(nearby_query_part(query, coordinate_params))
      end
      query
    end
  end
end
