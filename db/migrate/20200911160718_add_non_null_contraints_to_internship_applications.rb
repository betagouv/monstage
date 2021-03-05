class AddNonNullContraintsToInternshipApplications < ActiveRecord::Migration[6.0]
  def change
    change_column :internship_applications, :internship_offer_id, :bigint, null: false
    change_column :internship_applications, :internship_offer_type, :string, null: false
  end
end
