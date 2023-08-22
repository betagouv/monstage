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

      ministries = ministry_statistician.groups
      assert_equal 2, ministries.count
      assert ministries.all?{ |minister| minister.is_a?(Group) }
      assert ministries.all?{ |minister| minister.is_public? }
    end

  end
end