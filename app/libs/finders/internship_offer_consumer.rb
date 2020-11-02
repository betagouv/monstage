# frozen_string_literal: true

module Finders
  # build base query to request internship offers per user.type
  class InternshipOfferConsumer < ContextTypableInternshipOffer
    def mapping_user_type
      {
        Users::Operator.name => :visitor_query,
        Users::Employer.name => :visitor_query,
        Users::Visitor.name => :visitor_query,
        Users::SchoolManagement.name => :school_members_query,
        Users::Student.name => :school_members_query,
        Users::Statistician.name => :statistician_query,
        Users::God.name => :god_query
      }
    end

    private

    def school_members_query
      query = kept_offers_query

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
        query.in_the_future
             .published
             .ignore_internship_restricted_to_other_schools(school_id: user.school_id)
      end
      query
    end

    def statistician_query
      query = common_filter { kept_offers_query }
      query = query.merge(query.limited_to_department(user: user)) if user.department_name
      query
    end

    def visitor_query
      common_filter do
        kept_offers_query.in_the_future.published
      end
    end

    def god_query
      common_filter { kept_offers_query }
    end

    def kept_offers_query
      InternshipOffer.kept
    end
  end
end
