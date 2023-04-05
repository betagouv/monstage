class FixMissingInternshipOfferTypeMigration < ActiveRecord::Migration[6.0]
  def change
    InternshipOffer.where(type: 'InternshipOffers::Web').update_all(type: 'InternshipOffers')
  end
end
