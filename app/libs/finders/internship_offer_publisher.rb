# frozen_string_literal: true

module Finders
  # build base query to request internship offers per user.type
  class InternshipOfferPublisher < ContextTypableInternshipOffer
    def mapping_user_type
      {
        Users::Operator.name => :operator_query,
        Users::Employer.name => :employer_query,
        Users::Tutor.name => :tutor_query
      }
    end

    private

    def operator_query
      query = common_filter do
        InternshipOffer.kept.submitted_by_operator(user: user)
      end
      query = query.merge(query.limited_to_department(user: user)) if user.department_name.present?

      query
    end

    def employer_query
      common_filter do
        params[:filter] == 'approved' ? approved_filter : proposed_offers
      end
    end

    def tutor_query
      common_filter do
        params[:filter] == 'approved' ? approved_filter : proposed_offers
      end
    end

    def approved_filter
      offers_at       = InternshipOffer.arel_table
      applications_at = InternshipApplication.arel_table

      InternshipOffer.kept
                     .joins(:internship_applications)
                     .where(offers_at[:employer_id].eq(user.id))
                     .where(applications_at[:aasm_state].eq('approved'))
    end

    def proposed_offers
      user.internship_offers.kept
    end
  end
end
