# frozen_string_literal: true

require 'test_helper'

class EmployerMailerTest < ActionMailer::TestCase
  test '.internship_application_submitted_email can be delivered' do
    internship_application = create(:internship_application)
    email = EmployerMailer.internship_application_submitted_email(internship_application: internship_application)
    email.deliver_now
    assert_emails 1
  end

  test '.internship_application_submitted_email is delivered to expected users' do
    internship_application = create(:internship_application)
    email = EmployerMailer.internship_application_submitted_email(internship_application: internship_application)
    assert_equal [internship_application.internship_offer.employer.email], email.to
  end

  test '.internship_application_submitted_email includes handicap info' do
    student =create(:student, handicap: 'cotorep')
    internship_application = create(:internship_application, student: student)
    email = EmployerMailer.internship_application_submitted_email(internship_application: internship_application)
    assert email.decoded.include?(student.handicap)
  end
end
