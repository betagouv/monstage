
require 'test_helper'

class SingleApplicationReminderJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper
  include ThirdPartyTestHelpers

  setup { ActionMailer::Base.deliveries = [] }
  teardown { ActionMailer::Base.deliveries = [] }

  test 'send email with perform' do
    weeks_till_end = Week.selectable_from_now_until_end_of_school_year
    school = create(:school, :with_school_manager, weeks: [weeks_till_end.first])
    student = create(:student, school: school)
    internship_application = nil

    assert_changes -> {ActionMailer::Base.deliveries.count}, from: 0, to: 1 do 
      Triggered::SingleApplicationReminderJob.perform_now(student.id)
    end

    assert_no_changes -> {ActionMailer::Base.deliveries.count} do
      internship_application = create(:weekly_internship_application, :submitted, student: student)
    end

    student.update_columns(phone: '0606060606')
    student.reload
    assert_no_changes -> {ActionMailer::Base.deliveries.count} do
      sms_stub do
        assert_enqueued_jobs 0, only: SendSmsJob do
          Triggered::SingleApplicationReminderJob.perform_now(student.id)
        end
      end
    end
  end
end