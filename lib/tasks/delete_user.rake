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
    email_addresses << row[1]
  end

  email_addresses.each do |email|
    RemoveContactFromSyncEmailDeliveryJob.perform_later(email: email)
  end
  puts 'every single email removing is scheduled in Sidekiq'
end
