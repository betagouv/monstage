# frozen_string_literal: true

module Finders
  # build base query to request internship offers per user.type
  class InternshipOfferPublisher < ContextTypableInternshipOffer
    def mapping_user_type
      {
        Users::Operator.name => :operator_query,
        Users::Employer.name => :employer_query,
        Users::PrefectureStatistician.name => :statistician_query,
        Users::MinistryStatistician.name => :statistician_query,
        Users::EducationStatistician.name => :statistician_query
      }
    end

    private

    def operator_query
      query = common_filter do
        InternshipOffer.kept.where(employer: user)
      end

      query
    end

    def employer_query
      common_filter do
        params[:filter] == 'approved' ? approved_filter : proposed_offers
      end
    end

    def statistician_query
      common_filter do
        params[:filter] == 'approved' ? approved_filter : proposed_offers
      end
    end

    def approved_filter
      offers_at       = InternshipOffer.arel_table
      applications_at = InternshipApplication.arel_table

      InternshipOffer.kept
                     .joins(:internship_applications)
                     .where(offers_at[:employer_id].in(people_in_team_ids))
                     .where(applications_at[:aasm_state].eq('approved'))
    end

    def proposed_offers
      InternshipOffer.kept.where(employer_id: user.team_members_ids)
    end
  end
end
