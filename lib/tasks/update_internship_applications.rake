# frozen_string_literal: true

desc 'Update InternshipApplications with week_id'
task :create_week_id => :environment do |task|
  print "#{InternshipApplication.count} applications to modify..."
  
  InternshipApplication.find_each do |application|
    if application.internship_offer_week_id && !application.week_id
      week_id = InternshipOfferWeek.only(:week_id).find(application.internship_offer_week_id).week_id
    
      application.update_columns(week_id: week_id)
    end
    print '.'
  end

  print "\n"
  print 'done'
end
