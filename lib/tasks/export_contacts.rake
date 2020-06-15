require 'fileutils'
# usage : rails users:extract_email_data_csv

namespace :users do
  desc 'Export monstage DB users emails to Sendgrid contact DB'
  task :extract_email_data_csv, [] => :environment do
    say_in_green "Starting extracting emails metadata"

    require 'csv'

    targeted_fields = %i[email id type role first_name last_name confirmed_at]
    CSV.open("/tmp/export.csv", "w",force_quotes: true, quote_char: '"', col_sep: ",") do |csv|
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
                user.confirmed_at.utc.iso8601,
                'production']
      end
    end
    puts "File is written in #{dirname}/#{now}_email_users.csv"
    say_in_green 'task is finished'
  end

  def say_in_green(str)
    puts "\e[32m=====> #{str} <=====\e[0m"
  end
end
