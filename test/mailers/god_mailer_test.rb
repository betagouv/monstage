require 'test_helper'

class GodMailerTest < ActionMailer::TestCase
  include EmailSpamEuristicsAssertions

  test '.weekly_kpis_email sends email to recipient' do
    email = GodMailer.weekly_kpis_email
    email.deliver_now
    assert_emails 1
    assert_equal [EmailUtils.from], email.from
    assert_equal [ENV['TEAM_EMAIL']], email.to
    refute_email_spammyness(email)
  end
end