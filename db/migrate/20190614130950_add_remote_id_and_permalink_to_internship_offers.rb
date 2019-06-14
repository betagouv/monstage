class AddRemoteIdAndPermalinkToInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_offers, :remote_id, :string
    add_column :internship_offers, :permalink, :string
  end
end
