# frozen_string_literal: true

class RemoveColumnExcludedWeeksFromInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    remove_column :internship_offers, :excluded_weeks
    remove_column :internship_offers, :week_day_start
    remove_column :internship_offers, :week_day_end
    change_column :internship_offers, :max_internship_week_number, :integer, null: false, default: 1
    change_column :internship_offers, :sector_id, :integer, null: false
    change_column :internship_offers, :is_public, :boolean, null: false
    change_column :internship_offers, :tutor_name, :string, null: false
    change_column :internship_offers, :tutor_phone, :string, null: false
    change_column :internship_offers, :tutor_email, :string, null: false
    change_column :internship_offers, :employer_name, :string, null: false
    change_column_null :internship_offers, :employer_description, false, 'OCTO'
    change_column_null :internship_offers, :employer_street, false, 'Opéra'
    change_column_null :internship_offers, :employer_city, false, 'Paris'
    change_column_null :internship_offers, :employer_zipcode, false, '75015'
  end
end
