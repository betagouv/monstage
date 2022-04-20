# frozen_string_literal: true

require 'test_helper'

class EmployerMailerTest < ActionMailer::TestCase
  include ::EmailSpamEuristicsAssertions

  test '.internship_application_submitted_email delivers as expected' do
    student = create(:student, handicap: 'cotorep')
    internship_application = create(:weekly_internship_application, student: student)
    email = EmployerMailer.internship_application_submitted_email(internship_application: internship_application)
    email.deliver_now
    assert_emails 1
    assert_equal [internship_application.internship_offer.employer.email], email.to
    assert email.html_part.body.include?(student.handicap)
    refute_email_spammyness(email)
  end

  test '.internship_applications_reminder_email delivers as expected' do
    internship_application = create(:weekly_internship_application)
    email = EmployerMailer.internship_applications_reminder_email(
      employer: internship_application.internship_offer.employer,
      remindable_application_ids: [internship_application.id],
      expirable_application_ids: [internship_application.id]
    )
    email.deliver_now
    assert_emails 1
    assert_equal [internship_application.internship_offer.employer.email], email.to
    refute_email_spammyness(email)
  end

  test '.internship_approved_with_agreement_email delivers as expected' do
    internship_agreement = create(:internship_agreement)
    employer = internship_agreement.internship_application.internship_offer.employer
    email = EmployerMailer.internship_approved_with_agreement_email(
      internship_agreement: internship_agreement
    )
    email.deliver_now
    assert_emails 1
    assert_includes email.to, employer.email
    assert_equal 'Veuillez compléter la convention de stage.', email.subject
    refute_email_spammyness(email)
  end

  test '.school_manager_finished_notice_email delivers as expected' do
    internship_agreement = create(:internship_agreement)
    employer = internship_agreement.internship_application.internship_offer.employer
    email = EmployerMailer.school_manager_finished_notice_email(
      internship_agreement: internship_agreement
    )
    email.deliver_now
    assert_emails 1
    assert_includes email.to, employer.email
    assert_equal 'Imprimez et signez la convention de stage.', email.subject
    refute_email_spammyness(email)
  end
end
