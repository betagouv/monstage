class AddEmployerIdToInternshipOfferInfos < ActiveRecord::Migration[6.0]
  def change
    InternshipOfferInfo.destroy_all
    change_column :internship_offer_infos, :employer_id, :bigint, null: false
    add_foreign_key :internship_offer_infos, :users, column: :employer_id, primary_key: :id
  end
end
