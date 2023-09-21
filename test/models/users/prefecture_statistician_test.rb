require 'test_helper'

module Users
  class PrefectureStatisticianTest < ActiveSupport::TestCase
    test 'factory works' do
      prefecture_statistician = build(:prefecture_statistician)
      assert prefecture_statistician.valid?
    end

    test 'employer_like? true' do
      prefecture_statistician = create(:prefecture_statistician)
      assert prefecture_statistician.employer_like?
    end

  end
end