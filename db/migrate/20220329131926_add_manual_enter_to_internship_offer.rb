class AddManualEnterToInternshipOffer < ActiveRecord::Migration[6.1]
  def change
    add_column :organisations, :manual_enter, :boolean, default: false
    add_column :internship_offers, :employer_manual_enter, :boolean, default: false
  end
end
