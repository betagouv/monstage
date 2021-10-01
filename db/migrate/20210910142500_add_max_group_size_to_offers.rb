class AddMaxGroupSizeToOffers < ActiveRecord::Migration[6.1]
  def up
    add_column :internship_offer_infos, :max_students_per_group, :integer, default: 1, null: false
    add_column :internship_offers, :max_students_per_group, :integer, default: 1, null: false
    InternshipOffer.kept.find_each do |offer|
      offer.update_columns(max_students_per_group: offer.max_candidates)
    end
    InternshipOfferInfo.find_each do |offer_info|
      offer_info.update_columns(max_students_per_group: offer_info.max_candidates)
    end
  end

  def down
    remove_column :internship_offer_infos, :max_students_per_group
    remove_column :internship_offers, :max_students_per_group
  end
end
