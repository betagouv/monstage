require 'pretty_console'

# There's a business gotcha: the given email should NOT be a shared email or a generic one!

# Use it this way:
# ======================================
#   rake "migrations:from_school_manager_to_edu_stat[email:test@ac-amiens.fr;zipcode:67000]"
# ======================================

namespace :migrations do
  desc 'Migrate school_manager to dasen (or education statistician)'
  task :from_school_employee_to_edu_stat, [:identity] => :environment do |t, args|
    arguments = args.identity
    email = arguments.split(';').first.split(':').last
    zipcode = arguments.split(';').last.split(':').last

    user = User.find_by(email: email)
    short_zipcode =  if Department.departement_identified_by_3_chars?(zipcode: zipcode)
                       zipcode[0..2]
                     else
                       zipcode[0..1]
                     end

    if short_zipcode.nil?
        PrettyConsole.puts_in_red "Zipcode not found"
        raise "Zipcode not found"
    elsif user.nil? || !user.school_management?
      PrettyConsole.puts_in_red "User not found or not a school management"
    elsif
      user.school_manager? && user.send(:official_uai_email_address?)
      message = "User uses a shared email address, he should not be allowed" \
                " to become statistician with this email address. He should " \
                "change his email address first to a professional, yet personal one"
      PrettyConsole.puts_in_red message
    else
      ActiveRecord::Base.transaction do
        whitelist = EmailWhitelists::EducationStatistician.create_or_find_by(
          email: email,
          zipcode: short_zipcode
        )
        # skip emails with assign_email_whitelist_and_confirm
        user.becomes!(Users::EducationStatistician)
        user.school_id = nil
        user.role = :other
        user.save!
        message = "User email: #{user.email} is now an education statistician " \
                  "in #{short_zipcode} department"
        PrettyConsole.say_in_green message
      end
    end
  end
end