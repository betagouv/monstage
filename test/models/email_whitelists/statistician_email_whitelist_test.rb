# frozen_string_literal: true

require 'test_helper'

class StatisticianEmailWhitelistTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test 'send email after create' do
    assert_enqueued_emails 1 do
      create(:statistician_email_whitelist, email: 'kikoo@lol.fr', zipcode: '60')
    end
  end

  test 'destroy email whitelist also discard statistician' do
    statistician = create(:statistician)
    email_whitelist = create(:statistician_email_whitelist, email: statistician.email, user: statistician, zipcode: 60)
    freeze_time do
      assert_changes(-> { statistician.reload.discarded_at.try(:utc) },
                     from: nil,
                     to: Time.now.utc) do
        email_whitelist.destroy!
      end
    end
  end

 

  test 'sentry#1887500611 destroy email whitelist does not fails when no user' do
    email_whitelist = create(:statistician_email_whitelist, email: 'fourcade.m@gmail.com', zipcode: 60)

    assert_nothing_raised { email_whitelist.destroy! }
  end
end
