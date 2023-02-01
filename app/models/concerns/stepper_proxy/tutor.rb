# wrap shared behaviour between internship offer / tutor [by stepper]
module StepperProxy
  module Tutor
    extend ActiveSupport::Concern

    included do
      validates :tutor_name,
                :tutor_phone,
                :tutor_email,
                presence: true,
                unless: :from_api?
      validates :tutor_role,
                length: { minimum: 2, maximum: 150} ,
                unless: -> { tutor_role.blank? }

      def self.attributes_from_internship_offer(internship_offer_id:)
        internship_offer = InternshipOffer.find_by(id: internship_offer_id)
        return Tutor.new if internship_offer.nil?

        {
          tutor_name: internship_offer.tutor_name,
          tutor_phone: internship_offer.tutor_phone,
          tutor_email: internship_offer.tutor_email,
          tutor_role: internship_offer&.tutor_role,
          employer_id: internship_offer.employer_id
        }
      end

      def synchronize(internship_offer)
        parameters = InternshipOffers::WeeklyFramed.preprocess_tutor_to_params(self)
        internship_offer.update(parameters)
        internship_offer
      end
    end
  end
end
