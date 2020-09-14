class FixMissingInternshipOfferIdOnInternshipApplication < ActiveRecord::Migration[6.0]
  def change
    InternshipApplications::WeeklyFramed.where(internship_offer_id: nil).find_each do |ia|
      ia.internship_offer_id = ia.internship_offer_week.internship_offer.id
      ia.internship_offer_type = 'InternshipOffer'
      ia.save!
    end
  end
end
