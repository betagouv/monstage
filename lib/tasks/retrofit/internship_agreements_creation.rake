require 'pretty_console.rb'
# usage : rails users:extract_email_data_csv

namespace :retrofit do
  desc 'Export monstage DB users emails to Sendgrid contact DB'
  task :internship_agreements_creations, [] => :environment do
    PrettyConsole.say_in_green "Starting"
    ias = InternshipApplications::WeeklyFramed.approved
                                              .joins(:week)
                                              .merge(Week.selectable_from_now_until_end_of_school_year)
                                              .where('internship_applications.updated_at > ?', Date.new(2022,9,1))
    ias.first(1).each do |internship_application|
      puts internship_application.employer.email
      next if internship_application.internship_agreement.present?

      PrettyConsole.puts_in_yellow "Creating internship agreement for #{internship_application.student.presenter.full_name}"
      student      = internship_application.student
      main_teacher = student.main_teacher
      arg_hash     = {internship_application: self, main_teacher: main_teacher}

      if internship_application.type == "InternshipApplications::WeeklyFramed"
        internship_application.create_agreement
        if main_teacher.present?
          MainTeacherMailer.internship_application_approved_with_agreement_email(arg_hash)
                            .deliver_later
        end
      end
    end
  end
end
