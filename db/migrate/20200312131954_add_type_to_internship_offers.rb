class AddTypeToInternshipOffers < ActiveRecord::Migration[6.0]
  def change
    add_column :internship_offers, :type, :string
    InternshipOffer.from_api.update_all(type: 'InternshipOffers::Api')
    InternshipOffer.not_from_api.update_all(type: 'InternshipOffers')
  end
end
