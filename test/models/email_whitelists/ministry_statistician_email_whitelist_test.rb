# frozen_string_literal: true

require 'test_helper'

class MinistryStatisticianEmailWhitelistTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test 'send email after create' do
    valid_group = create(:group, is_public: true)
    assert_enqueued_emails 1 do
      create(:ministry_statistician_email_whitelist,
             email: 'kikoo@lol.fr',
             group: valid_group)
    end
  end

  test 'without valid group, one cannot create a ministry_statistician_email_whitelist' do
    invalid_group = create(:group, is_public: false)
    ministry_statistician_email_whitelist = build(:ministry_statistician_email_whitelist,
             email: 'kikoo@lol.fr',
             group: invalid_group)
    refute ministry_statistician_email_whitelist.valid?, "group should have been public, there's an error here"
  end

  test 'without group, one cannot create a ministry_statistician_email_whitelist' do
    invalid_group = create(:group, is_public: false)
    ministry_statistician_email_whitelist = build(:ministry_statistician_email_whitelist,
             email: 'kikoo@lol.fr',
             group: nil)
    refute ministry_statistician_email_whitelist.valid?, "group should have been public, there's an error here"
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
    ministry_email_whitelist = create(:statistician_email_whitelist, email: 'fourcade.m@gmail.com', zipcode: 60)

    assert_nothing_raised { ministry_email_whitelist.destroy! }
  end
end
