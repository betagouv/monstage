class RemoveCustomTrack < ActiveRecord::Migration[7.0]
  def change
    remove_column :internship_offers, :total_custom_track_convention_signed_applications_count
    remove_column :internship_offers, :total_custom_track_approved_applications_count
    remove_column :users, :custom_track
  end
end
