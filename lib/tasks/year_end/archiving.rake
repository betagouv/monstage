require 'pretty_console'

namespace :year_end do

def framing_with_announce(message)
  time = Time.now
  PrettyConsole.say_in_green("BEGIN: #{message}")
  yield
  PrettyConsole.say_in_green(" END: #{message.truncate(40)}")
  PrettyConsole.puts_in_yellow("--  Took #{Time.now - time} seconds")
  puts ' '
end

  desc 'archive students and unlink anonymized students from their class room'
  task :archive_students, [] => :environment do |args|
    framing_with_announce("Archiving students and unlinking anonymized students from their class room") do
      ActiveRecord::Base.transaction do
        Services::Archiver.new(begins_at: Date.new(2019,1,1))
        .archive_students
      end
    end
  end

  desc 'delete all invitations since they might be irrelevant after school year end'
  task :delete_invitations, [] => :environment do |args|
    framing_with_announce("Deleting invitations") do
      ActiveRecord::Base.transaction do
        Services::Archiver.new(begins_at: Date.new(2019,1,1))
                          .delete_invitations
      end
    end
  end

  desc 'anonymize all internship_agreements'
  task :anonymize_internship_agreements, [] => :environment do |args|
    framing_with_announce("Anonymizing internship agreements") do
      ActiveRecord::Base.transaction do
        Services::Archiver.new(begins_at: Date.new(2019,1,1))
                          .archive_internship_agreements
      end
    end
  end

  desc "remove url_shrinker's content"
  task :clean_url_shrinker, [] => :environment do |args|
    framing_with_announce("Clearing url_shrinker content") do
      UrlShrinker.delete_all
      puts "-- done"
    end
  end

  desc "anonymize and delete what should be after school year's end"
  task anonymize_and_delete: %i[archive_students
                                delete_invitations
                                anonymize_internship_agreements
                                clean_url_shrinker]
end