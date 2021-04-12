module Finders
  class TabEmployer
    def pending_agreements_count
      # internship_agreement approved with internship_agreement without terms_accepted
      @pending_internship_agreement_count ||= user.internship_applications
                                                  .approved
                                                  .troisieme_generale
                                                  .joins(:internship_agreement)
                                                  .where(internship_agreement: {employer_accept_terms: false})
                                                  .count

      # internship_applications approved without internship_agreement
      @to_be_created_internship_agreement ||= user.internship_applications
                                                  .approved
                                                  .troisieme_generale
                                                  .left_outer_joins(:internship_agreement)
                                                  .where(internship_agreement: {internship_application_id: nil})
                                                  .count
      [
        @pending_internship_agreement_count,
        @to_be_created_internship_agreement
      ].sum
    end

    private

    attr_reader :user

    def initialize(user:)
      @user = user
    end
  end
end
