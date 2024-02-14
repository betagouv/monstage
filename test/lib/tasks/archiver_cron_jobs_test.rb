
require 'test_helper'

class ArchiverCronJobsTest < ActiveSupport::TestCase
  # include ::EmailSpamEuristicsAssertions
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  test 'archive too old current_sign_in_at or teacher without school' do
    teacher = create(:teacher)
    create(:teacher, last_sign_in_at: 3.years.ago, current_sign_in_at: Date.today - 2.years- 10.minutes)
    teacher.update_columns(class_room_id: nil, school_id: nil)
    assert_equal 2, Users::SchoolManagement.kept.reload.count
    Monstage::Application.load_tasks
    Rake::Task['cleaning:archive_idle_teachers'].invoke
    assert_equal 0, Users::SchoolManagement.kept.reload.count
    clear_enqueued_jobs
  end

  test 'notify employer which offers are too old' do
    if ENV.fetch('RUN_BRITTLE_TEST', false)
      too_old = 2.years.ago - 10.day
      current_week_id = Week.current.id
      more_than_2_years_ago_in_weeks = 2 * 52 + 3
      older_weeks = [Week.find(current_week_id - more_than_2_years_ago_in_weeks -1), Week.find(current_week_id - more_than_2_years_ago_in_weeks)]
      assert InternshipOffer.count.zero?
      offer = create(:weekly_internship_offer,
                   weeks: older_weeks)
      assert_equal 1, InternshipOffer.count
      refute_nil offer.last_date
      assert offer.last_date < Date.today - 2.years + 2.weeks
      puts offer.inspect
      assert_emails 1 do
        assert_equal 1, InternshipOffer.kept.count
        puts "tested InternshipOffer.count : #{InternshipOffer.count}"
        assert_enqueued_with job:CleaningEmployerJob, args: [offer.employer_id] do
          Monstage::Application.load_tasks
          Rake::Task['cleaning:archive_idle_employers'].invoke
        end
      end
      InternshipOfferWeek.delete_all
      InternshipOffer.delete_all
      clear_enqueued_jobs
    end
  end

  test 'do not notify employer whose offers are not old enough at least for one' do
    if ENV.fetch('RUN_BRITTLE_TEST', false)
      too_old = 2.years.ago - 10.day
      current_week_id = Week.current.id
      older_weeks = [Week.find(current_week_id - 107), Week.find(current_week_id - 106)]
      offer = create(:weekly_internship_offer,
                    weeks:older_weeks)
      create(:weekly_internship_offer, employer_id: offer.employer_id)
      assert_equal 2, InternshipOffer.kept.count
      assert_no_emails do
        assert_no_enqueued_jobs do
          Monstage::Application.load_tasks
          Rake::Task['cleaning:archive_idle_employers'].invoke
        end
      end
      InternshipOfferWeek.delete_all
      InternshipOffer.delete_all
      clear_enqueued_jobs
    end
  end
end
