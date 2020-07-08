class AddInternshipOfferTypeToInternshipApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :internship_applications, :internship_offer_type, :string
  end
end
