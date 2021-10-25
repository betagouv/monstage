require 'fileutils'
# usage : rails users:extract_email_data_csv

namespace :users do
  desc 'Analysis'
  task :sum_up_data_csv, [] => :environment do
    say_in_green "Starting extracting emails "

    require 'csv'

    targeted_fields = %i[email]
    results = {'Users::Student': 0}
    table = CSV.parse(File.read("./tmp/adresses_email.csv"), headers: true)
    table.each do |line|
      user = User.find_by_email(line['email'])
      if user.present?
        results[user.class.name] = results[user.class.name].nil? ? 1 : results[user.class.name] + 1
      else
        results[:'Users::Student'] += 1
      end
    end
    p results unless results.blank?
    say_in_green 'task is finished'
  end

  def say_in_green(str)
    puts "\e[32m=====> #{str} <=====\e[0m"
  end
end