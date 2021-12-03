# frozen_string_literal: true

require 'test_helper'

class StudentMailerTest < ActionMailer::TestCase
  include EmailSpamEuristicsAssertions

  test 'email sent when internship application is approved' do
    internship_application = create(:weekly_internship_application)
    email = StudentMailer.internship_application_approved_email(internship_application: internship_application)

    email.deliver_now
    assert_emails 1
    assert_equal EmailUtils.from, email.from.first
    assert_equal [internship_application.student.email], email.to
    refute_email_spammyness(email)
  end

  test 'email sent when internship application is rejected' do
    internship_application = create(:weekly_internship_application)

    email = StudentMailer.internship_application_rejected_email(internship_application: internship_application)

    email.deliver_now
    assert_emails 1

    assert_equal EmailUtils.from, email.from.first
    assert_equal [internship_application.student.email], email.to
    refute_email_spammyness(email)
  end

  test 'email sent when internship application is canceled by employer' do
    internship_application = create(:weekly_internship_application)

    email = StudentMailer.internship_application_canceled_by_employer_email(
      internship_application: internship_application
    )

    email.deliver_now
    assert_emails 1

    assert_equal EmailUtils.from, email.from.first
    assert_equal [internship_application.student.email], email.to
    refute_email_spammyness(email)
  end
end
