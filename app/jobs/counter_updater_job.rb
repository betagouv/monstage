class CounterUpdaterJob < ActiveJob::Base
  queue_as :default

  def perform(year: 2022 )
    school_year = SchoolYear::Floating.new(date: Date.new(year,9,1))
    beginning_of_school_year = school_year.beginning_of_period
    internship_offers = InternshipOffer.kept
                                       .where('first_date >= ? ', beginning_of_school_year)
                                       .where('last_date < ? ', beginning_of_school_year + 1.year)
    kos_count = 0
    ok_count = 0
    internship_offers.find_each(batch_size: 300) do |internship_offer|
      result = Services::CounterManager.reset_one_internship_offer_counter(internship_offer: internship_offer)
      kos_count += result ? 0 : 1
      ok_count += result ? 1 : 0
    end
    message = kos_count.zero? ? "Everything is ok #{ok_count}" : "There were #{kos_count} KO"
    Rails.logger.info('----------------------------------------------------')
    Rails.logger.info message
  rescue StandardError => e
    Rails.logger.error("Error while resetting internship offer counters : #{e.message}")
    raise 'Error while resetting counters'
  end
end
