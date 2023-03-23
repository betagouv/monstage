# frozen_string_literal: true
require 'pretty_console.rb'

desc "School is over. Let's clean and prepare next year"
task school_end_year_archiving: :environment do
  ActiveRecord::Base.transaction do
    Users::Student.kept
                  .find_each do |student|
      student.archive
      print('.')
    end
    puts ''
    PrettyConsole.say_in_yellow " end of archiving students. "

    # duplicate all internship offers with dates stepping over next school years
    InternshipOffers::WeeklyFramed.kept
                                  .with_weeks_next_year
                                  .each do |internship_offer|
      new_internship_offer = internship_offer.split_in_two
      print('.')
      Services::CounterManager.reset_one_internship_offer_counter(
        internship_offer: new_internship_offer
      ) unless new_internship_offer.nil?
    end
    puts ''
    PrettyConsole.say_in_yellow " end of duplicating internship_offers with weeks on future school year. "
  end

  PrettyConsole.say_in_green 'All students are archived. Older internship offers are duplicated when possible.'
end
