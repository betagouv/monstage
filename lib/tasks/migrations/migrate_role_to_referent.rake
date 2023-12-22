require 'pretty_console'

# There's a business gotcha: the given email should NOT be a shared email or a generic one!

namespace :migrations do
  desc 'Migrate school_manager to dasen (or education statistician)'
  task :from_school_employee_to_edu_stat, [:identity] => :environment do |t, args|
    # Use it this way:
    # ======================================
    #   bundle exec rake "migrations:from_school_employee_to_edu_stat[email:test@ac-amiens.fr;zipcode:67000]"
    # ======================================
    arguments = args.identity
    email, zipcode = arguments.split(';').map { |arg| arg.split(':').last }

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
        # email sending is avoided from user existence test
        user.becomes!(Users::EducationStatistician)
        user.school_id = nil
        user.role = :other
        user.department = short_zipcode
        user.save!
        message = "User email: #{user.email} is now an education statistician " \
                  "in #{short_zipcode} department"
        PrettyConsole.say_in_green message
      end
    end
  end

  desc 'Migrate employer to dasen (or education statistician)'
  task :from_employer_to_edu_stat, [:identity] => :environment do |t, args|
    # Use it this way:
    # ======================================
    #   bundle exec rake "migrations:from_employer_to_edu_stat[email:test@ac-amiens.fr;zipcode:67000;agreement_signatorable:true]"
    # ======================================
    arguments = args.identity
    email, zipcode, signatorable = arguments.split(';').map { |arg| arg.split(':').last }
    signatorable = signatorable[0...-1] == "true"

    user = User.find_by(email: email)
    short_zipcode =  if Department.departement_identified_by_3_chars?(zipcode: zipcode)
                       zipcode[0..2]
                     else
                       zipcode[0..1]
                     end

    if short_zipcode.nil?
        PrettyConsole.puts_in_red "Zipcode not found"
        raise "Zipcode not found"
    elsif user.nil? || !user.employer?
      PrettyConsole.puts_in_red "User not found or not an employer"
    else
      ActiveRecord::Base.transaction do
        # skip emails sending from user existence test
        user.becomes!(Users::EducationStatistician)
        user.save!
        message = "User email: #{user.email} is now an education statistician " \
                  "in #{short_zipcode} department"
        PrettyConsole.puts_in_green message
        user.agreement_signatorable = signatorable
        # Following line will trigger internship_agreement creations fo internship_offers which end_date is in the future
        user.save!

        new_user = User.find_by(email: email)
        PrettyConsole.say_in_red('Invalid Object') and raise 'invalid migration' unless new_user.valid?
        PrettyConsole.say_in_heavy_white "as user is agreement signatorable, it may have created internship_agreements" if signatorable
      end
    end
  end

  desc 'Migrate employer to statistician (or departmental statistician)'
  task :from_employer_to_departmental_statistician, [:identity] => :environment do |t, args|
    # Use it this way:
    # ======================================
    #   bundle exec rake "migrations:from_employer_to_departmental_statistician[email:test@free.fr;zipcode:67000;agreement_signatorable:true]"
    # ======================================
    arguments = args.identity
    email, zipcode, signatorable = arguments.split(';').map { |arg| arg.split(':').last }
    signatorable = signatorable[0...-1] == "true"

    user = User.find_by(email: email)
    short_zipcode =  if Department.departement_identified_by_3_chars?(zipcode: zipcode)
                       zipcode[0..2]
                     else
                       zipcode[0..1]
                     end

    if short_zipcode.nil?
        PrettyConsole.puts_in_red "Zipcode not found"
        raise "Zipcode not found"
    elsif user.nil? || !user.employer?
      PrettyConsole.puts_in_red "User not found or not an employer"
    else
      ActiveRecord::Base.transaction do
        # skip emails sending from user existence test
        user.becomes!(Users::PrefectureStatistician)
        user.save!
        message = "User email: #{user.email} is now an departmental statistician " \
                  "in #{short_zipcode} department"
        PrettyConsole.puts_in_green message
        user.agreement_signatorable = signatorable
        # Following line will trigger internship_agreement creations fo internship_offers which end_date is in the future
        user.save!

        new_user = User.find_by(email: email)
        PrettyConsole.say_in_red('Invalid Object') and raise 'invalid migration' unless new_user.valid?
        PrettyConsole.say_in_heavy_white "as user is agreement signatorable, it may have created internship_agreements" if signatorable
      end
    end
  end
end