module Finders
  class TabEmployer
    def pending_agreements_count
      # internship_agreement draft
      user.internship_agreements
          .draft
          .count
    end

    def pending_internship_applications_actions_count
      pending_states = %i[read_by_employer submitted examined]
      internship_offer_ids = user.internship_offers&.kept&.ids
      return 0 if internship_offer_ids.blank?

      InternshipApplications::WeeklyFramed.where( internship_offer_id: internship_offer_ids )
                                          .where(aasm_state: pending_states)
                                          .filtering_discarded_students
                                          .count

    end

    def pending_agreements_actions_count
      return 0 if user.operator?

      count = user.internship_agreements
                  .kept
                  .where(aasm_state: [:draft, :started_by_employer, :validated])
                  .filtering_discarded_students
                  .count

      count += user.internship_agreements
                   .filtering_discarded_students
                   .kept
                   .signatures_started
                   .joins(:signatures)
                   .where.not(signatures: {signatory_role: :employer} )
                   .count
    end

    def agreements_count
      user.internship_agreements.kept.count
    end

    private

    attr_reader :user

    def initialize(user:)
      @user = user
    end
  end
end
