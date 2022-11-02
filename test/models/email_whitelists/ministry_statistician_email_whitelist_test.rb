# frozen_string_literal: true

require 'test_helper'

class MinistryStatisticianEmailWhitelistTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test 'send email after create' do
    assert_enqueued_emails 1 do
      create(:ministry_statistician_email_whitelist, email: 'kikoo@lol.fr')
    end
  end

  test 'without valid group, one cannot create a ministry_statistician_email_whitelist' do
    invalid_group = create(:group, is_public: false)
    ministry_statistician_email_whitelist = create(
      :ministry_statistician_email_whitelist,
      email: 'kikoo@lol.fr'
    )
    assert_equal 2, ministry_statistician_email_whitelist.reload.groups.size

    ministry_statistician_email_whitelist.groups << invalid_group
    assert_equal 2, ministry_statistician_email_whitelist.reload.groups.size,
           "group should have been public, there's an error here"
  end

  test 'destroy email whitelist also discard statistician' do
    ministry_statistician = create(:ministry_statistician)
    ministry_email_whitelist = ministry_statistician.ministry_email_whitelist
    freeze_time do
      assert_changes(-> { ministry_statistician.reload.discarded_at.try(:utc) },
                     from: nil,
                     to: Time.now.utc) do
        ministry_email_whitelist.destroy!
      end
    end
  end

  test 'sentry#1887500611 destroy email whitelist does not fails when no user' do
    ministry_email_whitelist = create(:statistician_email_whitelist)

    assert_nothing_raised { ministry_email_whitelist.destroy! }
  end
end
