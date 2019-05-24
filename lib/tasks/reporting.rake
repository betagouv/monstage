# frozen_string_literal: true

namespace :reporting do
  desc 'Refresh internship offer reporting materialized table'
  task refresh_internship_offers: :environment do
    puts 'Refreshing materialized view...'
    puts Reporting::InternshipOffer.refresh.inspect
  end
end
