class SetDefaultValueOfMaxCandidatesInInternshipOffers < ActiveRecord::Migration[5.2]
  def up
    InternshipOffer.where(max_candidates: nil).each do |internship_offer|
      internship_offer.update_attribute(:max_candidates, 1)
    end
  end
end
