class AddMaxGroupSizeToOffers < ActiveRecord::Migration[6.1]
  def up
    add_column :internship_offer_infos, :max_student_group_size, :integer, default: 1, null: false
    add_column :internship_offers, :max_student_group_size, :integer, default: 1, null: false
    InternshipOffer.find_each do |offer|
      offer.update_columns(max_student_group_size: offer.max_candidates)
    end
    InternshipOfferInfo.find_each do |offer_info|
      offer_info.update_columns(max_student_group_size: offer_info.max_candidates)
    end
  end

  def down
    remove_column :internship_offer_infos, :max_student_group_size
    remove_column :internship_offers, :max_student_group_size
  end
end
