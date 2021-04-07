# frozen_string_literal: true

namespace :school_year_is_over do
  # We currently archive all class rooms
  # It is possible to archive users before or after the class rooms
  desc "School is over. Let's clean and prepare next year"

  task archive_class_rooms: :environment do |_task|
    archive_service.archive_class_rooms
    say_in_green 'all class rooms are now archived'
  end

  task archive_students: :environment do |_task|
    archive_service.archive_students
    say_in_green 'all students are archived. Email data base ' \
                 '(mailjet currently) updated with jobs'
  end

  task archive: :environment do |_task|
    archive_service.perform
    say_in_green 'all entities are now archived'
  end

  def archive_service
    SchoolYear::Archiver.new
  end

  def say_in_green(str)
    puts "\e[32m=====> #{str} <=====\e[0m"
  end
end
