class AddCoordinatesColumnToInternshipOffers < ActiveRecord::Migration[5.2]
  def change
    change_table :internship_offers do |t|
      t.st_point :coordinates, geographic: true
      t.index :coordinates, using: :gist
    end
  end
end
