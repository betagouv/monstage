class OffresVoiePro < ActiveRecord::Migration[7.0]
  def up
    InternshipOffer.where(type: "InternshipOffers::FreeDate").update_all(type: "InternshipOffers::WeeklyFramed")
    InternshipOfferInfo.where(type: "InternshipOfferInfos::FreeDate").update_all(type: "InternshipOffers::WeeklyFramed")
  end
end
