
require 'test_helper'

class SingleApplicationReminderJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper
  include ThirdPartyTestHelpers

  setup { ActionMailer::Base.deliveries = [] }
  teardown { ActionMailer::Base.deliveries = [] }

  test 'perform job does not raise notification since no other application is possible' do
    internship_application = nil
    student = nil
    travel_to Time.zone.local(2020, 1, 1, 12, 0, 0) do
      weeks_till_end = Week.selectable_from_now_until_end_of_school_year
      school = create(:school, :with_school_manager, weeks: [weeks_till_end.first])
      student = create(:student, school: school)
      assert student.phone.blank?
      internship_offer = create(:weekly_internship_offer,
                                weeks: [weeks_till_end.first],
                                employer: create(:employer))
      internship_application = create(:weekly_internship_application,
                                      :drafted,
                                      internship_offer: internship_offer,
                                      student: student)

      assert student.internship_applications.count == 1
      refute student.has_offers_to_apply_to?
      sms_stub do
        assert_enqueued_jobs 0, only: SendSmsJob do
          assert_changes -> {::ActionMailer::Base.deliveries.count}, from: 0, to: 0 do
            internship_application.submit
          end
        end
      end
    end
  end

  test 'perform job does raise a notification as email' do
    internship_application = nil
    student = nil
    travel_to Time.zone.local(2020, 1, 1, 12, 0, 0) do
      weeks_till_end = Week.selectable_from_now_until_end_of_school_year
      school = create(:school, :with_school_manager, weeks: [weeks_till_end.first])
      student = create(:student, school: school)
      assert student.phone.blank?
      internship_offer_ref = create(:weekly_internship_offer,
                                    weeks: [weeks_till_end.first],
                                    employer: create(:employer))
      internship_offer = create(:weekly_internship_offer,
                                weeks: [weeks_till_end.first],
                                employer: create(:employer))
      internship_application = create(:weekly_internship_application,
                                      :drafted,
                                      internship_offer: internship_offer,
                                      student: student)

      assert student.internship_applications.count == 1
      assert student.has_offers_to_apply_to?
    end
    travel_to Time.zone.local(2020, 1, 3, 12, 0, 0) do
      sms_stub do
        assert_enqueued_jobs 0, only: SendSmsJob do
          assert_changes -> {::ActionMailer::Base.deliveries.count}, from: 0, to: 1 do
            internship_application.submit
          end
        end
      end
    end
  end

  test 'perform job does raise a notification as sms' do
    internship_application = nil
    student = nil
    travel_to Time.zone.local(2020, 1, 1, 12, 0, 0) do
      weeks_till_end = Week.selectable_from_now_until_end_of_school_year
      school = create(:school, :with_school_manager, weeks: [weeks_till_end.first])
      student = create(:student, school: school, phone: '+330623443058')
      internship_offer_ref = create(:weekly_internship_offer,
                                    weeks: [weeks_till_end.first],
                                    employer: create(:employer))
      internship_offer = create(:weekly_internship_offer,
                                weeks: [weeks_till_end.first],
                                employer: create(:employer))
      internship_application = create(:weekly_internship_application,
                                      :drafted,
                                      internship_offer: internship_offer,
                                      student: student)
      sms_stub do
        assert_enqueued_jobs 1, only: SendSmsJob do
          assert_no_changes -> {::ActionMailer::Base.deliveries.count} do
            internship_application.submit
          end
        end
      end

      # with an extra application, application count exceeds 1
      sms_stub do
        assert_no_enqueued_jobs do
          assert_no_changes -> {::ActionMailer::Base.deliveries.count} do
            create(:weekly_internship_application,
                                      :drafted,
                                      internship_offer: internship_offer_ref,
                                      student: student).submit
          end
        end
      end
    end
  end
end
# assert_no_changes -> {ActionMailer::Base.deliveries.count} do
#   internship_application = create(:weekly_internship_application, :drafted, student: student)
#   internship_application.submit
# end

# student.update_columns(phone: '0606060606')
# student.reload
# assert_no_changes -> {ActionMailer::Base.deliveries.count} do
#   sms_stub do
#     assert_enqueued_jobs 0, only: SendSmsJob do
#       Triggered::SingleApplicationReminderJob.perform_now(student.id)
#     end
#   end
# end