require 'pretty_console.rb'
# usage : rake retrofit:internship_agreements_creations

namespace :retrofit do
  desc 'Retrofit de création de conventions de stage'
  task :internship_agreements_creations, [] => :environment do
    PrettyConsole.say_in_green "Starting"
    counter = 0
    week_ids = ((Week.current.id + 1)..(Week.current.id.to_i + 33)).to_a
    employer_internship_offer_ids = InternshipOffer.kept
                                                   .published
                                                   .where(employer_id: User.employers.ids)
    ias = InternshipApplication.approved
                                              .joins(:week)
                                              .where(week_id: week_ids)
                                              .where(internship_offer_id: employer_internship_offer_ids)
                                              .where('internship_applications.updated_at > ?', Date.new(2022,9,1))
    ActiveRecord::Base.transaction do
      ias.each do |internship_application|
        next if internship_application.internship_agreement.present?

        PrettyConsole.puts_in_yellow "Creating internship agreement for #{internship_application.student.presenter.full_name}"
        student      = internship_application.student
        main_teacher = student.main_teacher
        arg_hash     = {internship_application: internship_application, main_teacher: main_teacher}

        internship_application.create_agreement
        if main_teacher.present?
          MainTeacherMailer.internship_application_approved_with_agreement_email(arg_hash)
                           .deliver_later
        end
        
        counter += 1
      end
    end
    PrettyConsole.say_in_green "Done with #{counter} internship agreements created"
  end
end