# frozen_string_literal: true

module Finders
  # build base query to request internship offers per user.type
  class UserTypableInternshipOffer
    MappingUserTypeWithScope = {
      # same query for all kind of school memnbers
      Users::MainTeacher.name => :school_members_query,
      Users::Student.name => :school_members_query,
      Users::Other.name => :school_members_query,
      Users::SchoolManager.name => :school_members_query,
      Users::Student.name => :school_members_query,
      Users::Teacher.name => :school_members_query,
      # custom queries for other kind of users
      Users::Employer.name => :employer_query,
      Users::Operator.name => :operator_query,
      Users::Statistician.name => :statistician_query,
      Users::Visitor.name => :visitor_query,
      Users::God.name => :god_query
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
    end

    def employer_query
      query = user.internship_offers.kept
      query = query.merge(nearby_query_part(query, coordinate_params)) if coordinate_params
      query
    end

    def god_query
      query = InternshipOffer.kept
      query = query.merge(nearby_query_part(query, coordinate_params)) if coordinate_params
      query
    end

    def school_members_query
      coordinates = coordinate_params || user.try(:school).try(:coordinates)
      query = InternshipOffer.kept
                             .available_in_the_future
                             .published
                             .ignore_internship_restricted_to_other_schools(school_id: user.school_id)
                             .ignore_max_candidates_reached
                             .ignore_max_internship_offer_weeks_reached
      query = query.merge(nearby_query_part(query, coordinates) ) if coordinates
      query = query.merge(query.internship_offers_overlaping_school_weeks(weeks: user.school.weeks)) if !user.missing_school_weeks? && user.school
      query = query.merge(query.ignore_already_applied(user: user)) if user.respond_to?(:internship_applications)
      query
    end

    def operator_query
      query = InternshipOffer.kept.mines_and_sumbmitted_to_operator(user: user)
      if coordinate_params
        query = query.merge(nearby_query_part(query, coordinate_params))
      elsif user.department_name.present?
        query = query.merge(query.limited_to_department(user: user))
      end
      query
    end

    def statistician_query
      query = InternshipOffer.kept
      query = query.merge(nearby_query_part(query, coordinate_params)) if coordinate_params
      query = query.merge(query.limited_to_department(user: user)) if user.department_name
      query
    end

    def visitor_query
      query = InternshipOffer.kept.available_in_the_future.published
      query = query.merge(nearby_query_part(query, coordinate_params)) if coordinate_params
      query
    end


    def coordinate_params
      return nil unless params.key?(:latitude) || params.key?(:longitude)
      geo_point_factory(latitude: params[:latitude], longitude: params[:longitude])
    end

    def radius_params
      return Nearbyable::DEFAULT_NEARBY_RADIUS_IN_METER unless params.key?(:radius)
      params[:radius]
    end
  end
end
