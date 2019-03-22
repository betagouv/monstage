class CreateInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    create_table :internship_offers do |t|
      t.string  :title, null: false
      t.text    :description, null: false
      t.string  :sector
      t.boolean :can_be_applied_for, default: true
      t.date    :week_day_start
      t.date    :week_day_end
      t.date    :excluded_weeks, array: true
      t.integer :max_candidates
      t.integer :max_internship_number

      t.string  :tutor_name
      t.string  :tutor_phone
      t.string  :tutor_email
      t.string  :employer_website
      t.text    :employer_description
      t.text    :employer_street
      t.string  :employer_zipcode
      t.string  :employer_city
      t.string  :supervisor_email
      t.boolean :is_public

      t.timestamps
    end
  end
end
