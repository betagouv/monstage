# frozen_string_literal: true

namespace :school_year_is_over do
  # We currently archive all class rooms
  # It is possible to archive users before or after the class rooms
  desc "School is over. Let's clean and prepare next year"

  task class_rooms_archive: :environment do |_task|
    ClassRoom.anonymize!
    say_in_green 'all class rooms are now archived'
  end

  task students_archive: :environment do |_task|
    Users::Student.kept.find_each do |student|
      student.anonymize(send_email: false)
    end
    say_in_green 'all students are archived. Email data base ' \
                 '(mailjet currently) updated with jobs'
  end

  def say_in_green(str)
    puts "\e[32m=====> #{str} <=====\e[0m"
  end
end
