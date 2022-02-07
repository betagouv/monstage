# frozen_string_literal: true

desc 'Update InternshipApplications with week_id'
task :create_week_id => :environment do |task|
  print "#{InternshipApplication.count} applications to scan..."
  updated_count = 0

  InternshipApplication.find_each do |application|
    if application.internship_offer_week_id && !application.week_id
      week_id = InternshipOfferWeek.only(:week_id).find(application.internship_offer_week_id).week_id

      application.update_columns(week_id: week_id)
      print '.'
      updated_count += 1
    end
  end

  print "\n"
  print "updated applications count : #{updated_count}"
  print "\n"
  print 'done'
  print "\n"
end
