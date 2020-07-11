class AddApplicableTypeToInternshipOffers < ActiveRecord::Migration[6.0]
  def change
    add_column :internship_applications, :applicable_type, :string
  end
end
