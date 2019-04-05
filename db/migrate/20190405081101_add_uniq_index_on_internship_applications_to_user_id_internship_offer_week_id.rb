class AddUniqIndexOnInternshipApplicationsToUserIdInternshipOfferWeekId < ActiveRecord::Migration[5.2]
  def change
    InternshipApplication.all.map do |ia|
      ia.destroy! unless ia.valid?
    end
    add_index :internship_applications, [:user_id, :internship_offer_week_id],
                                        unique: true,
                                        name: 'uniq_applications_per_internship_offer_week'
  end
end
