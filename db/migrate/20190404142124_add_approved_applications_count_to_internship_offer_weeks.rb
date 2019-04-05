class AddApprovedApplicationsCountToInternshipOfferWeeks < ActiveRecord::Migration[5.2]
  def change
    add_column :internship_offer_weeks, :approved_applications_count, :integer, null: false, default: 0
  end
end
