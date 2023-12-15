# frozen_string_literal: true

require 'test_helper'
class CancelValidatedInternshipApplicationJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test 'cancel application' do
    internship_offer = create(:weekly_internship_offer, :published, max_candidates: 1)
    internship_application = create(:weekly_internship_application, :validated_by_employer, internship_offer: internship_offer)
    assert_equal 'validated_by_employer', internship_application.reload.aasm_state
    assert_equal 1, internship_offer.internship_applications.count

    CancelValidatedInternshipApplicationJob.perform_now(internship_application_id: internship_application.id)

    assert_equal 'expired_by_student', internship_application.reload.aasm_state
  end
end
