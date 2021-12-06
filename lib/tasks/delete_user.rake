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
