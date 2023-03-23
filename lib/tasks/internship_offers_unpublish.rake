desc 'To be scheduled in cron at 6 am to update selected internship offers status to unpublished'
task internship_offers_unpublish: :environment do
  Rails.logger.info("----------------------------------------")
  Rails.logger.info("Cron runned at #{Time.now.utc}(UTC), internship_offers_unpublish")
  Rails.logger.info("----------------------------------------")
  ActiveRecord::Base.transaction do
    to_be_unpublished = InternshipOffer.published.where('last_date < ?', Time.now.utc).to_a
    to_be_unpublished += InternshipOffer.published.where('remaining_seats_count < 1').to_a
    to_be_unpublished.uniq.each do |offer|
      print '.'
      offer.unpublish!
    end
    puts ' Done !'
  end
end