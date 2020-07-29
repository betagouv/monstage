class RemoveOrganisationConstraintOnOffers < ActiveRecord::Migration[6.0]
  def up
    change_column :internship_offers, :title, :string, null: true
    change_column :internship_offers, :street, :string, null: true
    change_column :internship_offers, :zipcode, :string, null: true
    change_column :internship_offers, :city, :string, null: true
    change_column :internship_offers, :description, :string, null: true
    change_column :internship_offers, :is_public, :boolean, null: true
    change_column :internship_offers, :employer_description, :string, null: true
    change_column :internship_offers, :employer_name, :string, null: true
    change_column :internship_offers, :sector_id, :bigint, null: true
  end

  def down
    change_column :internship_offers, :title, :string, null: false
    change_column :internship_offers, :street, :string, null: false
    change_column :internship_offers, :zipcode, :string, null: false
    change_column :internship_offers, :city, :string, null: false
    change_column :internship_offers, :description, :string, null: false
    change_column :internship_offers, :is_public, :boolean, null: false
    change_column :internship_offers, :employer_description, :string, null: false
    change_column :internship_offers, :employer_name, :string, null: false
    change_column :internship_offers, :sector_id, :bigint, null: false
  end
end
