# frozen_string_literal: true
module Finders
  class ListableInternshipOffer
    DEFAULT_NEARBY_RADIUS_IN_METER = 60_000

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
      query = InternshipOffer.kept.available_in_the_future
      query = scopes_for_user(query)
      query = query.group(:id)
      query = query.page(params[:page]) # force kaminari interface no matter presence of page param
      query
    end

    def nearby_query_part(query, coordinates)
      query.nearby(latitude: coordinates.latitude,
                   longitude: coordinates.longitude,
                   radius: radius_params)
    end

    def scopes_for_user(query)
      case user
      when Users::Employer
        query = query.merge(user.internship_offers)
      when Users::God
        query = query.merge(nearby_query_part(query, coordinate_params)) if coordinate_params
      when Users::MainTeacher,
           Users::Student,
           Users::Other,
           Users::SchoolManager,
           Users::Student,
           Users::Teacher
        query = query.published
        coordinates = coordinate_params || user.try(:school).try(:coordinates)
        query = query.merge(nearby_query_part(query, coordinates) ) if coordinates
        query = query.merge(query.internship_offers_overlaping_school_weeks(weeks: user.school.weeks)) if !user.missing_school_weeks? && user.school
        query = query.merge(query.ignore_internship_restricted_to_other_schools(school_id: user.school_id))
        query = query.merge(query.ignore_max_candidates_reached)
        query = query.merge(query.ignore_max_internship_offer_weeks_reached)
        query = query.merge(query.ignore_already_applied(user: user)) if user.respond_to?(:internship_applications)
      when Users::Operator
        query = query.merge(query.mines_and_sumbmitted_to_operator(user: user))
        if coordinate_params
          query = query.merge(nearby_query_part(query, coordinate_params)) if coordinate_params
        elsif user.department_name.present?
          query = query.merge(query.limited_to_department(user: user))
        end
        query
      when Users::Statistician
        query = query.merge(nearby_query_part(query, coordinate_params)) if coordinate_params
        query = query.merge(query.limited_to_department(user: user)) if user.department_name
      when Users::Visitor
        query = query.merge(nearby_query_part(query, coordinate_params)) if coordinate_params
        query = query.merge(InternshipOffer.published)
      else
        fail "unknown user"
      end
      query
    end

    def coordinate_params
      return nil unless params.key?(:latitude) || params.key?(:longitude)
      geo_point_factory(latitude: params[:latitude], longitude: params[:longitude])
    end

    def radius_params
      return DEFAULT_NEARBY_RADIUS_IN_METER unless params.key?(:radius)
      params[:radius]
    end
  end
end
