require 'pretty_console'
# usage : rake retrofit:internship_agreements_creations

namespace :retrofit do
  desc "depublication d'offres par email d'employeurs"
  task :unpublish_from_email_list, [:emails] => :environment do |t, args|
    PrettyConsole.say_in_green 'Starting'
    PrettyConsole.print_in_cyan 'use with'
    PrettyConsole.print_in_cyan 'bundle exec rake "retrofit:unpublish_from_email_list[email1 email2 email3]"'
    counter = 0
    email_list = args[:emails].split(/\s+/)
    puts ''
    puts 'email list'
    puts '----------'
    puts email_list

    employer_ids = Users::Employer.where(email: email_list).ids
    InternshipOffers::WeeklyFramed.kept
                                  .published
                                  .where(employer_id: employer_ids)
                                  .each do |offer|
      counter += 1
      submitted_applications = offer.internship_applications.submitted
      next if submitted_applications.any?

      offer.update_columns(published_at: nil, aasm_state: :unpublished)
    end
    puts ''

    PrettyConsole.say_in_green "Done with #{counter} internship offer unpublished"
  end
end
