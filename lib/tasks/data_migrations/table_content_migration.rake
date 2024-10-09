require 'pretty_console'
require 'csv'

namespace :data_migrations do
  desc 'school data export'
  task school_data_file: :environment do |task|
    PrettyConsole.announce_task 'create school data file' do
      file = 'school_data.csv'
      CSV.open(file, 'wb') do |csv|
        csv << %w[name city department zipcode code_uai coordinates street created_at
                  updated_at city_tsv kind visible internship_agreement_online fetched_school_phone]
        School.all.each do |school|
          csv << [school.name, school.city, school.department, school.zipcode, school.code_uai, school.coordinates,
                  school.street, school.created_at, school.updated_at, school.city_tsv, school.kind, school.visible, school.internship_agreement_online, school.fetched_school_phone]
        end
      end
    end
  end
end
