module Finders
  class TabEmployer
    def pending_agreements_count
      # internship_agreement draft
      user.internship_agreements
          .draft
          .count
    end

    def pending_internship_offers_actions(internship_offers)
       internship_offers.map(&:internship_applications)
                        .map(&:submitted)
                        .map(&:count)
                        .sum
    end

    def pending_agreements_actions_count
      return 0 if user.operator?

      count = user.internship_agreements
                  .where(aasm_state: [:draft, :started_by_employer, :validated])
                  .count
      count += user.internship_agreements
                   .signatures_started
                   .joins(:signatures)
                   .where.not(signatures: {signatory_role: :employer} )
                   .count
    end

    def agreements_count
      user.internship_agreements.count
    end

    private

    attr_reader :user

    def initialize(user:)
      @user = user
    end
  end
end
