# frozen_string_literal: true
require 'fileutils'
require 'pretty_console'

namespace :students do
  desc 'Reminder for students with pending internship applications'
  task :pending_internship_applications_reminder, [] => [:environment] do |args|
    PrettyConsole.say_in_green 'Starting students:pending_internship_applications_reminder'
    students = Users::Student.kept.select do |student|
      student.internship_applications.validated_by_employer.present?
    end

    PrettyConsole.say_in_red "Found #{students.count} students with pending internship applications"

    students.each do |student|
      puts "Sending sms to #{student.email}"

      internship_application = student.internship_applications.validated_by_employer.first
      Triggered::StudentSmsInternshipApplicationReminderJob.new(internship_application.id).perform_now
    end
    PrettyConsole.say_in_green 'Finished students:pending_internship_applications_reminder'

    GodMailer.students_global_applications_reminder(students.count).deliver_now
  end
end
