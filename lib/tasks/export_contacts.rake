require 'fileutils'
# usage : rails users:extract_email_data_csv

namespace :users do
  desc 'Export monstage DB users emails to Sendgrid contact DB'
  task :extract_email_data_csv, [] => :environment do
    say_in_green "Starting extracting emails metadata"

    targeted_fields = %i[email id role first_name last_name confirmed_at]

    dirname = 'tmp/extracts'
    unless File.directory?(dirname)
      FileUtils.mkdir_p(dirname)
    end

    extract = User.all.pluck(*targeted_fields).to_a

    # Headers
    file_content = '' # or following line
    file_content = "environment,#{targeted_fields.map(&:to_s).join(',')}\n"

    extract.each do |line|
      csv_line = "production, #{line.to_csv }" #default is production
      file_content += csv_line
    end

    puts 'Extract is done...'

    now = Time.zone.now.strftime '%Y-%m-%d'
    File.open("tmp/extracts/#{now}_email_users.csv", 'w') do |file|
      file.puts file_content
    end

    puts "File is written in #{dirname}/#{now}_email_users.csv"
    say_in_green 'task is finished'
  end

  def say_in_green(str)
    puts "\e[32m=====> #{str} <=====\e[0m"
  end
end