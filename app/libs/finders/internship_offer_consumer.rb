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

    def school_management_query
      common_filter do
        kept_offers_query.in_the_future
                         .published
                         .ignore_internship_restricted_to_other_schools(school_id: user.school_id)
      end
    end

    def school_members_query
      school_management_query
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
