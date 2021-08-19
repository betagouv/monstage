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
        Users::Statistician.name => :statistician_query,
        Users::MinistryStatistician.name => :ministry_statistician_query,
        Users::God.name => :god_query
      }
    end

    private

    def kept_offers_query
      InternshipOffer.kept
    end

    def god_query
      common_filter { kept_offers_query.published }
    end

    def school_track_by_class_room_query(query)
      query.merge(
        InternshipOffer.school_track(school_track: user.try(:school_track))
      )
    end

    def school_management_query
      common_filter do
        kept_offers_query.in_the_future
                         .published
                         .ignore_internship_restricted_to_other_schools(school_id: user.school_id)
      end
    end

    def school_members_query
      query = school_management_query
      query = school_track_by_class_room_query(query) if user.try(:school_track)

      # WeeklyFramed offers are dedicated to :troisieme_generale and API
      if user.try(:class_room).try(:fit_to_weekly?)
        unless user.missing_school_weeks?
          query = query.merge(
            weekly_framed_scopes(:internship_offers_overlaping_school_weeks, {weeks: user.school.weeks})
          )
        end
        query = query.merge(
          weekly_framed_scopes(:ignore_already_applied, {user: user})
        )
        query = query.merge(
          weekly_framed_scopes(:ignore_max_candidates_reached)
        )
        query = query.merge(
          weekly_framed_scopes(:ignore_max_internship_offer_weeks_reached)
        )
      elsif user.try(:class_room).try(:fit_to_free_date?)
        query = query.merge(InternshipOffers::FreeDate.ignore_already_applied(user: user))
      end
      query
    end

    def statistician_query
      god_query.tap do |query|
        query.merge(query.limited_to_department(user: user)) if user.department
      end
    end

    def ministry_statistician_query
      god_query.limited_to_ministry(user: user)
    end

    def visitor_query
      common_filter { kept_offers_query.in_the_future.published }
    end
  end
end
