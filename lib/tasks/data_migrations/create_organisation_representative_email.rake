# nov 12 , 2022
require 'pretty_console'

namespace :data_migrations do
  desc 'Fullfil organisation_representative_email field in internship_agreements'
  task :create_organisation_representative_email => :environment do |task|
    PrettyConsole.puts_with_white_background "Starting task : #{task.name}"
    ActiveRecord::Base.transaction do
        InternshipAgreement.kept.each do |agreement|
            agreement.update(organisation_representative_email: agreement.internship_application.internship_offer.employer.email)
            print '.'
        end
    end

    puts ''
    PrettyConsole.say_in_green 'Task completed'
    end
end


