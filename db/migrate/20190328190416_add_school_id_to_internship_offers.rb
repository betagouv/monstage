class AddSchoolIdToInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_offers, :school_id, :bigint
    add_foreign_key :internship_offers, :schools, column: :school_id, primary_key: :id
  end
end
