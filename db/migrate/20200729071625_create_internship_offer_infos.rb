class CreateInternshipOfferInfos < ActiveRecord::Migration[6.0]
  def change
    create_table :internship_offer_infos do |t|
      t.string :title
      t.text :description
      t.integer :max_candidates
      t.integer :school_id
      t.integer :employer_id
      t.string :type
      t.belongs_to :sector
      t.date :first_date
      t.date :last_date
      t.integer :weeks_count, null: false, default: 0
      t.integer :internship_offer_info_weeks_count, null: false, default: 0
      t.text :weekly_hours, array: true, default: []
      t.text :daily_hours, array: true, default: []

      t.timestamps
    end
  end
end
