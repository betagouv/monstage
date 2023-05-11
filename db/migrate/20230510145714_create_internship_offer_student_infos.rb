class CreateInternshipOfferStudentInfos < ActiveRecord::Migration[7.0]
  def change
    create_table :internship_offer_student_infos do |t|
      
      t.integer :max_candidates
      t.integer :school_id

      t.integer :employer_id  
      t.date :last_date

      t.integer :weeks_count, null: false, default: 0

      t.integer :internship_offer_student_info_weeks_count, null: false, default: 0

      t.jsonb :daily_hours, default: {}
      t.text :weekly_hours, array: true, default: []
      t.text :weekly_lunch_break

      t.integer :max_students_per_group, default: 1, null: false
      t.integer :remaining_seats_count, default: 0

      t.timestamps
    end
  end
end
