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
end
