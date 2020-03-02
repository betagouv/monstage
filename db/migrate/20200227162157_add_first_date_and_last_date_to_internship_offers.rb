class AddFirstDateAndLastDateToInternshipOffers < ActiveRecord::Migration[6.0]
  def change
    add_column :internship_offers, :first_date, :date
    add_column :internship_offers, :last_date, :date

    InternshipOffer.find_each do |io|
      io.sync_first_and_last_date
      io.save
    end
  end
end
