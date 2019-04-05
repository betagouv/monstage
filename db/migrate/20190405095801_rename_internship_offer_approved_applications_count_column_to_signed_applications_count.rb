class RenameInternshipOfferApprovedApplicationsCountColumnToSignedApplicationsCount < ActiveRecord::Migration[5.2]
  def change
    rename_column :internship_offers, :approved_applications_count, :convention_signed_applications_count
    add_column :internship_offers, :approved_applications_count, :integer, null: false, default: 0
  end
end
