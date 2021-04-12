# frozen_string_literal: true

require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  include EmailSpamEuristicsAssertions

  test '.anonymize_user sends email to recipient' do
    recipient_email = 'fourcade.m@gmail.com'
    email = UserMailer.anonymize_user(recipient_email: recipient_email)
    email.deliver_now
    assert_emails 1
    assert_equal [EmailUtils.from], email.from
    assert_equal [recipient_email], email.to
    refute_email_spammyness(email)
  end

  test 'after tutor creation, it sends an email' do
    internship_offer = create(:troisieme_generale_internship_offer)
    tutor = internship_offer.tutor
    email = TutorMailer.new_tutor(tutor.id, internship_offer.id)
    email.deliver_now
    assert_equal 'Vous avez été désigné tuteur de stage', email.subject
    assert_equal [EmailUtils.from], email.from
    assert_equal [tutor.email], email.to
    refute_email_spammyness(email)
  end
end
