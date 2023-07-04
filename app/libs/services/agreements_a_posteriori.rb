module Services
  class AgreementsAPosteriori
    def perform
      ActiveRecord::Base.transaction do
        InternshipOffers::WeeklyFramed.where(employer_id: employer.id)
                                      .in_the_future
                                      .each do |offer|

          offer.internship_applications
              .approved
              .each do |application|
            next unless application_valid_for_agreement?(application)

            application.create_agreement
          end
        end
      end
    end

    private

    attr_reader :employer

    def application_valid_for_agreement?(application)
      no_agreement_yet?(application) &&
        school_manager_email_present?(application) &&
        employer_agreement_signatorable?(application)
    end

    def no_agreement_yet?(application)
      application.internship_agreement.blank?
    end

    def school_manager_email_present?(application)
      application.student.school&.school_manager&.email&.present?
    end

    def employer_agreement_signatorable?(application)
      application.internship_offer.employer.agreement_signatorable?
    end

    def initialize(employer_id:)
      @employer = User.find(employer_id)
    end
  end
end