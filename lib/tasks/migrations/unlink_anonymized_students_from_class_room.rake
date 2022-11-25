# File to move to data_migration while updating the namespace

namespace :migrations do
  desc 'Migrate group_id to ministry_group table'
  task :unlink_anonymized_students_from_class_room, [] => :environment do |args|
    ActiveRecord::Base.transaction do
      Services::StudentArchiver.new(begins_at: Date.new(2019,1,1), ends_at:Date.new(2023,7,1))
                               .archive_class_room_student_link
    end
  end
end
