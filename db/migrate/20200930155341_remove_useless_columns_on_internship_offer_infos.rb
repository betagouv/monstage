class RemoveUselessColumnsOnInternshipOfferInfos < ActiveRecord::Migration[6.0]
  def change
    remove_column :internship_offer_infos, :first_date
  end
end
