require 'fileutils'
require 'pretty_console.rb'
require 'csv'
# usage : rails users:extract_email_data_csv

namespace :users do
  desc 'Export monstage DB users emails to Sendgrid contact DB'
  task :extract_email_data_csv, [] => :environment do
    PrettyConsole.say_in_green "Starting extracting emails metadata"

    require 'csv'

    targeted_fields = %i[email id type role first_name last_name confirmed_at]
    dir_name = 'tmp'
    CSV.open("#{dir_name}/export.csv", "w+", force_quotes: true, quote_char: '"', col_sep: ",") do |csv|
      csv << [].concat(targeted_fields, ['environment'])

      User.where.not(confirmed_at: nil)
          .where.not(type: Users::Student.name)
          .where(discarded_at: nil)
          .all
          .each do |user|
        csv << [
                user.email,
                user.id,
                user.type,
                user.role,
                user.first_name,
                user.last_name,
                user.confirmed_at.utc.to_i,
                'production']
      end
    end
    now=Time.now.strftime("%Y-%m-%d")
    FileUtils.mkdir_p(dir_name) unless File.directory?(dir_name)
    puts "File is written in #{dir_name}/#{now}_email_users.csv"
    PrettyConsole.say_in_green 'task is finished'
  end

  desc 'Export monstage DB users with school_manager roles when two school_managers operate in the same school'
  task :extract_double_school_manager_csv, [] => :environment do
    PrettyConsole.say_in_heavy_white "Starting extracting school_manager metadata"

    school_ids = User.select('users.school_id', 'count(users.school_id)')
                     .where(role: 'school_manager')
                     .group(:school_id)
                     .having('count(users.school_id) > 1')
                     .map {|group| group.school_id}

    school_managers = User.kept
                          .where.not(confirmed_at: nil)
                          .where(role: 'school_manager')
                          .where(school_id: school_ids)

    targeted_fields = %i[email id school_id role current_sign_in_at confirmed_at created_at updated_at]
    CSV.open( "tmp/export_double_school_managers_by_school.csv",
              "w+",
              force_quotes: true,
              quote_char: '"',
              col_sep: ",") do |csv|

      csv << [].concat(targeted_fields, [Rails.env])

      school_managers.each do |school_manager|
        csv << [ school_manager.email,
                 school_manager.id,
                 school_manager.school_id,
                 school_manager.role,
                 school_manager.current_sign_in_at,
                 school_manager.confirmed_at,
                 school_manager.created_at,
                 school_manager.updated_at,
                 'production' ]
      end
    end
    if school_managers.count.zero?
      PrettyConsole.say_in_green 'No double school_manager found'
    else
      PrettyConsole.puts_in_red "Found #{school_managers.count} double school_manager"
      PrettyConsole.say_in_green 'task is finished , see : tmp/export_double_school_managers_by_school.csv'
    end
  end
end
