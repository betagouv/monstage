# frozen_string_literal: true

require 'test_helper'

class StatisticianEmailWhitelistMailerTest < ActionMailer::TestCase
  include EmailSpamEuristicsAssertions

  test 'send email to recipient email' do
    new_email = 'kikoo@lol.fr'
    email_whitelist  = create(:ministry_statistician_email_whitelist, email: new_email)
    email = MinistryStatisticianEmailWhitelistMailer.notify_ready(recipient_email: new_email)
    email.deliver_now
    assert_emails 1
    assert_equal [new_email], email.to
    refute_email_spammyness(email)
  end
end
