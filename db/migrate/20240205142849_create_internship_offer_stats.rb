class CreateInternshipOfferStats < ActiveRecord::Migration[7.1]
  def change
    create_table :internship_offer_stats do |t|
      t.references :internship_offer, null: false, foreign_key: true
      t.integer :remaining_seats_count, default: 0
      t.integer :blocked_weeks_count, default: 0
      t.integer :total_applications_count, default: 0
      t.integer :approved_applications_count, default: 0
      t.integer :submitted_applications_count, default: 0
      t.integer :rejected_applications_count, default: 0
      t.integer :view_count, default: 0 
      t.integer :total_male_applications_count, default: 0
      t.integer :total_female_applications_count, default: 0
      t.integer :total_male_approved_applications_count, default: 0
      t.integer :total_female_approved_applications_count, default: 0

      t.timestamps
    end

    add_index :internship_offer_stats, :remaining_seats_count
    add_index :internship_offer_stats, :blocked_weeks_count
    add_index :internship_offer_stats, :total_applications_count
  end
end
