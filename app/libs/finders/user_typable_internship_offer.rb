# frozen_string_literal: true

module Finders
  # build base query to request internship offers per user.type
  class UserTypableInternshipOffer

    protected

    attr_reader :user, :params


    def nearby_query_part(query, coordinates)
      query.nearby(latitude: coordinates.latitude,
                   longitude: coordinates.longitude,
                   radius: radius_params)
           .with_distance_from(latitude: coordinates.latitude,
                               longitude: coordinates.longitude)
    end

    def school_members_query
      query = InternshipOffer.all

      if user.try(:middle_school?) && school_type_param != 'high_school'
        unless user.missing_school_weeks?
          query = query.merge(
            InternshipOffers::WeeklyFramed.internship_offers_overlaping_school_weeks(weeks: user.school.weeks)
          )
        end
        query = query.merge(InternshipOffers::WeeklyFramed.ignore_already_applied(user: user))
        query = query.merge(InternshipOffers::WeeklyFramed.ignore_max_candidates_reached)
        query = query.merge(InternshipOffers::WeeklyFramed.ignore_max_internship_offer_weeks_reached)

      elsif user.try(:high_school) && school_type_param != 'middle_school'
        query = query.merge(InternshipOffers::FreeDate.ignore_already_applied(user: user))
      end

      query = common_filter do
        query.kept
             .in_the_future
             .published
             .ignore_internship_restricted_to_other_schools(school_id: user.school_id)
      end
      query
    end

    def employer_query
      common_filter do
        user.internship_offers.kept
      end
    end

    def operator_query
      query = common_filter do
        InternshipOffer.kept.submitted_by_operator(user: user)
      end
      query = query.merge(query.limited_to_department(user: user)) if user.department_name.present?
      query
    end

    def statistician_query
      query = common_filter do
        InternshipOffer.kept
      end
      query = query.merge(query.limited_to_department(user: user)) if user.department_name
      query
    end

    def visitor_query
      common_filter do
        InternshipOffer.kept.in_the_future.published
      end
    end

    def god_query
      common_filter do
        InternshipOffer.kept
      end
    end

    def school_type_param
      return nil unless params.key?(:school_type)

      params[:school_type]
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

    def common_filter
      query = yield
      query = keyword_query(query) if keyword_params
      query = nearby_query(query) if coordinate_params
      query = middle_school_query(query) if school_type_param == 'middle_school'
      query = high_school_query(query) if school_type_param == 'high_school'
      query
    end

    def keyword_query(query)
      query.merge(InternshipOffer.search_by_keyword(params[:keyword]).group(:rank))
    end

    def nearby_query(query)
      query.merge(nearby_query_part(query, coordinate_params))
    end

    def middle_school_query(query)
      query.merge(InternshipOffer.weekly_framed)
    end

    def high_school_query(query)
      query.merge(InternshipOffer.free_date)
    end
  end
end
