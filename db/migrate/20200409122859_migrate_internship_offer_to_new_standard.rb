class MigrateInternshipOfferToNewStandard < ActiveRecord::Migration[6.0]
  def change
    InternshipOffer.find_each do |io|
      io.sync_first_and_last_date
      io.title = io.title.truncate(150)
      io.description = io.description.truncate(500)
      puts "one stange io: #{io.id}" unless io.save
    end
  end
end
