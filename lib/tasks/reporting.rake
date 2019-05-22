namespace :reporting do
  desc "Refresh internship offer reporting materialized table"
  task refresh_internship_offers: :environment do
    puts Reporting::InternshipOffer.refresh.inspect
  end

end
