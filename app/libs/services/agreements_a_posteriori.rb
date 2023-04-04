module Services
  class AgreementsAPosteriori
    def perform
      ActiveRecord::Base.transaction do
        InternshipOffers.where(employer: employer)
                                      .in_the_future
                                      .each do |offer|

          offer.internship_applications
              .approved
              .each do |application|
            next unless application.student&.school&.school_manager&.email
            next if application.internship_agreement&.present?

            application.create_agreement
          end
        end
      end
    end

    private

    attr_reader :employer

    def initialize(employer_id:)
      @employer = User.find(employer_id)
    end
  end
end