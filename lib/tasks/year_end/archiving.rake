namespace :year_end do
  desc 'archive students and unlink anonymized students from their class room'
  task :archive_students, [] => :environment do |args|
    ActiveRecord::Base.transaction do
      Services::Archiver.new(begins_at: Date.new(2019,1,1), ends_at:Date.new(2023,9,1))
                        .archive_students
    end
  end

  desc 'delete all invitations since they might be irrelevant after school year end'
  task :delete_invitations, [] => :environment do |args|
    ActiveRecord::Base.transaction do
      Services::Archiver.new(begins_at: Date.new(2019,1,1), ends_at:Date.new(2023,9,1))
                        .delete_invitations
    end
  end

  desc 'anonymize and delete what should be after year end'
  task anonymize_and_delete: [:archive_students, :delete_invitations]
end