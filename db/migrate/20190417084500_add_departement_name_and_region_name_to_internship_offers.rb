# frozen_string_literal: true

class AddDepartementNameAndRegionNameToInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_offers, :department, :string, null: false, default: ''
    add_column :internship_offers, :region, :string, null: false, default: ''
    add_column :internship_offers, :academy, :string, null: false, default: ''
    rename_column :internship_offers, :employer_street, :street
    rename_column :internship_offers, :employer_zipcode, :zipcode
    rename_column :internship_offers, :employer_city, :city
    rename_column :schools, :departement_name, :department
  end
end
