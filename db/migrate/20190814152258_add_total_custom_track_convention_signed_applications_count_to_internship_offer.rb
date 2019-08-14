class AddTotalCustomTrackConventionSignedApplicationsCountToInternshipOffer < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_offers, :total_custom_track_convention_signed_applications_count, :integer, null: false, default: 0
  end
end
