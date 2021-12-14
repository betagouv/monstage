# frozen_string_literal: true

desc 'Remove all information about a user (RGPD)'
task :delete_user, [:user_id] => :environment do |task, args|
  user_id = args.user_id

  puts "Removing all information about user #{user_id}..."

  user = User.find(user_id)
  user.anonymize

  puts 'done'
end

desc 'Remote contacts of email delivery service'
task :delete_remote_contacts => [:environment] do
  require 'fileutils'
  require 'csv'

  email_addresses = []

  CSV.foreach(Rails.root.join('tmp/adresses_email.csv'), headers: { col_sep: ',' }).each.with_index do |row, i|
    email_address = row[1]
    domain = email_address.split('@').second
    next if 'domain.invalid' == domain

    email_addresses << email_address
  end

  puts "Deleting #{email_addresses.count} accounts"

  email_addresses.each do |email|
    sleep 1
    RemoveContactFromSyncEmailDeliveryJob.perform_later(email: email)
  end
  puts 'every single email removing is scheduled in Sidekiq'
end

desc 'Anonymize idle employers from a specific school year'
task :delete_idle_employers, [:school_year] => [:environment] do |t, args|
  school_year = args.school_year || (Date.today - 2.years).year
  trigerring_date = Date.new(school_year.to_i, 9, 1)

  if trigerring_date.is_a?(Date) && (trigerring_date < Date.today - 1.year)
    reconnected_employers_ids = Users::Employer.kept
                    .where.not(confirmed_at: nil)
                    .where('last_sign_in_at >= ?', trigerring_date)
                    .where('current_sign_in_at >= ?', trigerring_date)
                    .ids
    puts "reconnected_employers_ids #{reconnected_employers_ids.count}"
    identified_exceptions_ids = Users::Operator.ids
    puts "identified_exceptions_ids #{identified_exceptions_ids.count}"
    in_white_list = reconnected_employers_ids + identified_exceptions_ids
    employers = Users::Employer.where.not(id: in_white_list)
    puts "Ready to anonymize #{employers.count}"
    employers.each do |employer|
      sleep 0.3
      puts "##{employer.id} | "
      employer.anonymize(send_email: false)
    end
    if employers.size.zero?
      puts "nothing to do"
    else
      puts "idle employers from september 1st #{school_year} are anonymized"
    end
  else
    puts "this year is too early"
  end
end
