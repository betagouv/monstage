# frozen_string_literal: true

require 'test_helper'

class EmployerMailerTest < ActionMailer::TestCase
  include ::EmailSpamEuristicsAssertions
  include TeamAndAreasHelper

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
      remindable_application_ids: [internship_application.id]
    )
    email.deliver_now
    assert_emails 1
    assert_equal [internship_application.internship_offer.employer.email], email.to
    refute_email_spammyness(email)
  end

  test '.internship_application_approved_with_agreement_email delivers as expected' do
    internship_agreement = create(:internship_agreement)
    employer = internship_agreement.internship_application.internship_offer.employer
    email = EmployerMailer.internship_application_approved_with_agreement_email(
      internship_agreement: internship_agreement
    )
    email.deliver_now
    assert_emails 1
    assert_includes email.to, employer.email
    assert_equal 'Veuillez compléter la convention de stage.', email.subject
    refute_email_spammyness(email)
  end

  test '.internship_application_approved_with_agreement_email does not deliver when notifications are off' do
    internship_agreement = create(:internship_agreement)
    employer = internship_agreement.internship_application.internship_offer.employer
    create_team(employer, create(:employer))

    internship_agreement.internship_application
                        .internship_offer
                        .internship_offer_area
                        .area_notifications
                        .find_by(user_id: employer.id)
                        .update(notify: false)

    email = EmployerMailer.internship_application_approved_with_agreement_email(
      internship_agreement: internship_agreement
    )
    email.deliver_now
    assert_emails 0
  end

  test '.internship_application_approved_with_agreement_email does not deliver when notifications are off with user_operators' do
    operator               = create(:operator)
    user_operator          = create(:user_operator, operator: operator)
    internship_offer       = create(:weekly_internship_offer, employer: user_operator)
    internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
    internship_agreement   = create(:internship_agreement, internship_application: internship_application)
    create_team(user_operator, create(:user_operator, operator: operator))

    internship_agreement.internship_offer_area
                        .area_notifications
                        .find_by(user_id: user_operator.id)
                        .update(notify: false)

    email = EmployerMailer.internship_application_approved_with_agreement_email(
      internship_agreement: internship_agreement
    )
    email.deliver_now
    assert_emails 0
  end

  test '.internship_application_approved_with_agreement_email does not deliver when notifications are off with department statisticians' do
    statistician          = create(:statistician, agreement_signatorable: true)
    internship_offer       = create(:weekly_internship_offer, employer: statistician)
    internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
    internship_agreement   = create(:internship_agreement, internship_application: internship_application)
    create_team(statistician, create(:statistician, agreement_signatorable: true))

    internship_agreement.internship_offer_area
                        .area_notifications
                        .find_by(user_id: statistician.id)
                        .update(notify: false)

    email = EmployerMailer.internship_application_approved_with_agreement_email(
      internship_agreement: internship_agreement
    )
    email.deliver_now
    assert_emails 0
  end

  test '.resend_internship_application_submitted_email delivers as expected' do
    internship_application = create(:weekly_internship_application, :validated_by_employer)
    employer = internship_application.internship_offer.employer
    email = EmployerMailer.resend_internship_application_submitted_email(
      internship_application: internship_application
    )
    email.deliver_now
    assert_emails 1
    assert_includes email.to, employer.email
    assert_equal '[Relance] Vous avez une candidature en attente', email.subject
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
