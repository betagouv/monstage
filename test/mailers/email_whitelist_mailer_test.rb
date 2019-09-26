# frozen_string_literal: true

require 'test_helper'

class EmailWhitelistMailerTest < ActionMailer::TestCase
  test 'send email to recipient email' do
    new_email = 'kikoo@lol.fr'
    email = EmailWhitelistMailer.notify_ready(recipient_email: new_email)
    email.deliver_now
    assert_emails 1
    assert_equal [new_email], email.to
  end
end
