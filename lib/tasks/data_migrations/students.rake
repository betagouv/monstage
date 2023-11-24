
require 'pretty_console'

namespace :data_migrations do
  desc 'Update students confirmation to ok'
  task :confirm_all_students => :environment do |task|
    PrettyConsole.announce_task "Updating students confirmation to ok" do
      Users::Student.kept.where(confirmed_at: nil).each do |student|
        student.confirmed_at = student.created_at + 1.second
        student.save
      end
      Users::Student.where(confirmed_at: nil).each do |student|
        student.confirmed_at = Date.today
        student.save
      end
    end
  end
end
    
