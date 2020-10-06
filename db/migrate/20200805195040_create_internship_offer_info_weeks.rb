class CreateInternshipOfferInfoWeeks < ActiveRecord::Migration[6.0]
  def change
    create_table :internship_offer_info_weeks do |t|
      t.belongs_to :internship_offer_info, foreign_key: true
      t.belongs_to :week, foreign_key: true
      t.integer :total_applications_count, null: false, default: 0
      
      t.timestamps
    end
  end
end
