
require 'pretty_console'

namespace :cleaning do
  desc 'archive teachers without schools or who have not been active for 2 years'
  task :archive_idle_teachers, [] => :environment do |args|
    PrettyConsole.announce_task("Archiving teachers without schools or who have not been active for 2 years") do
      teachers = Users::SchoolManagement.kept.where(role: :teacher)
      user_ids_to_be_anonymized =  teachers.where(school_id: nil).ids
      user_ids_to_be_anonymized += teachers.where('current_sign_in_at < ?', 2.years.ago).ids
      user_ids_to_be_anonymized.to_a.uniq.each do |id|
        UserAnonymizerJob.new.perform(user_id: id)
        PrettyConsole.print_in_yellow "."
      end
    end
  end

  task :archive_idle_employers, [] => :environment do |args|
    puts '(not implemented yet)'
    puts ' '
  end

  task task confidentiality_cleaning: %i[archive_idle_teachers
                                         archive_idle_employers ]
end
