# frozen_string_literal: true

namespace :data_migrations do
  desc 'Rename statisticians to prefecture statisticians'
  task :rename_statisticians => :environment do |task|
    statisticians = User.where(type: 'Users::Statistician')
    print "#{statisticians.count} statisticians to convert..."
    updated_count = 0

    statisticians.find_each do |statistician|
      statistician.update_column(type: 'Users::PrefectureStatistician')
      print '.'
      updated_count += 1
    end

    print "\n"
    print "updated statisticians count : #{updated_count}"
    print "\n"
    print 'done'
    print "\n"
  end
end
