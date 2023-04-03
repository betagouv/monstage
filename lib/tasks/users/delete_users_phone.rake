# frozen_string_literal: true
namespace :users do
  desc 'Remove all old user phone'
  task :delete_users_phone => :environment do |task|
    
    users = User.where.not(phone: nil)
    puts "Removing phone for #{users.size} users..."
    users.each { |u| u.update(phone: nil) } 
    puts 'done'
  end
end
