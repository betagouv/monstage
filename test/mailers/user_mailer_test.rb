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

  test '.export_offers ministry_statistician' do
    ministry_statistician = create(:ministry_statistician)

    email = UserMailer.export_offers(ministry_statistician, {})
    assert_nothing_raised do
      Timeout::timeout(5) do
        email.deliver_now
      end
    end
    assert_equal "Export des offres de monstagedetroisieme", email.subject
    refute_email_spammyness(email)
  end

  test '.export_offers user god' do
    god = create(:god)

    email = UserMailer.export_offers(god, {})
    assert_nothing_raised do
      Timeout::timeout(10) do
        email.deliver_now
      end
    end
    assert_equal "Export des offres de monstagedetroisieme", email.subject
    refute_email_spammyness(email)
  end
  test '.export_offers user god with departement param' do
    god = create(:god)

    email = UserMailer.export_offers(god, {department: 'Oise'})
    assert_nothing_raised do
      Timeout::timeout(10) do
        email.deliver_now
      end
    end
    assert_equal "Export des offres de monstagedetroisieme", email.subject
    refute_email_spammyness(email)
  end
end
