require 'test_helper'

module Users
  class StatisticianTest < ActiveSupport::TestCase
    test 'factory works' do
      ministry_statistician = build(:ministry_statistician)
      assert ministry_statistician.valid?
    end

    test 'factory test' do
      ministry_statistician = create(:ministry_statistician)
      assert ministry_statistician.valid?
      assert ministry_statistician.is_a?(Users::MinistryStatistician)

      whitelist = ministry_statistician.ministry_email_whitelist
      assert whitelist.is_a?(EmailWhitelists::Ministry)

      ministries = whitelist.groups
      assert_equal 2, ministries.count
      assert ministries.all?{ |minister| minister.is_a?(Group) }
      assert ministries.all?{ |minister| minister.is_public? }
    end

    test 'destroy email whitelist also discard statistician' do
      ministry_statistician    = create(:ministry_statistician)
      ministry_email_whitelist = ministry_statistician.ministry_email_whitelist
      freeze_time do
        assert_changes(-> { ministry_statistician.reload.discarded_at.try(:utc) },
                       from: nil,
                       to: Time.now.utc) do
          ministry_email_whitelist.destroy!
        end
      end
    end
  end
end