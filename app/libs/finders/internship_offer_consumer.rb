# frozen_string_literal: true

module Finders
  # build base query to request internship offers per user.type
  class InternshipOfferConsumer < ContextTypableInternshipOffer
    def mapping_user_type
      {
        Users::Operator.name => :visitor_query,
        Users::Employer.name => :visitor_query,
        Users::Visitor.name => :visitor_query,
        Users::SchoolManagement.name => :school_management_query,
        Users::Student.name => :school_members_query,
        Users::PrefectureStatistician.name => :statistician_query,
        Users::MinistryStatistician.name => :ministry_statistician_query,
        Users::EducationStatistician.name => :statistician_query,
        Users::God.name => :visitor_query
      }
    end

    def available_offers(max_distance: MAX_RADIUS_SEARCH_DISTANCE)
      student_query = kept_published_future_offers_query.ignore_already_applied(user: user) # Whatever application status !!!
      return student_query if user.school.nil? || user.school.weeks.empty?

      school_week_ids  = user.school.weeks.map(&:id)
      school_latitude  = user.school.coordinates&.latitude
      school_longitude = user.school.coordinates&.longitude
      student_query = student_query.joins(:internship_offer_weeks)
                                   .where(internship_offer_weeks: { week_id: school_week_ids })
                                   .ignore_internship_restricted_to_other_schools(school_id: user.school_id)
      return student_query if school_latitude.nil? || school_longitude.nil?

      student_query.nearby_and_ordered(latitude: school_latitude,
                                       longitude: school_longitude,
                                       radius: max_distance)
    end

    private

    def light_kept_published_future_offers_query
      InternshipOffer.kept
                     .published
                     .with_seats
                     .in_the_future
    end

    def kept_published_future_offers_query
      light_kept_published_future_offers_query.includes([:sector])
    end

    def school_management_query
      common_filter do
        light_kept_published_future_offers_query.ignore_internship_restricted_to_other_schools(
          school_id: user.school_id
        )
      end
    end

    def school_members_query
      school_management_query.ignore_already_applied(user: user)
    end

    def statistician_query
      visitor_query.tap do |query|
        query.merge(query.limited_to_department(user: user)) if user.department
      end
    end

    def ministry_statistician_query
      visitor_query.limited_to_ministry(user: user)
    end

    def visitor_query
      common_filter { light_kept_published_future_offers_query}
    end
  end
end
