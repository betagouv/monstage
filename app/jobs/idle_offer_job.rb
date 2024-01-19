
class IdleOfferJob < ApplicationJob
  queue_as :default

 def perform(internship_offer_id:)
    internship_offer = InternshipOffer.find(internship_offer_id)
    if internship_offer.aasm_state == "drafted"
      EmployerMailer.idle_offer_email(internship_offer: internship_offer)
                    .deliver_later
    end
  end
end