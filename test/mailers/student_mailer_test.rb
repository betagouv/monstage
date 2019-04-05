require 'test_helper'

class StudentMailerTest < ActionMailer::TestCase
  test "email sent when internship application is approved" do
    internship_application = create(:internship_application)

    email = StudentMailer.internship_application_approved_email(internship_application: internship_application)

    email.deliver_now
    assert_emails 1
    assert_equal [internship_application.internship_offer.employer.email], email.from
    assert_equal [internship_application.student.email], email.to
  end

  test "email sent when internship application is declined" do

    internship_application = create(:internship_application)

    email = StudentMailer.internship_application_rejected_email(internship_application: internship_application)

    email.deliver_now
    assert_emails 1
    assert_equal ['ne-pas-repondre@monstagede3e.fr'], email.from
    assert_equal [internship_application.student.email], email.to
  end
end
