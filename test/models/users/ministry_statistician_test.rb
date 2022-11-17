require 'test_helper'

module Users
  class MinistryStatisticianTest < ActiveSupport::TestCase
    test 'factory works' do
      # email_whitelist = create(:ministry_statistician_email_whitelist)
      ministry_statistician = build(:ministry_statistician)
      assert ministry_statistician.valid?
    end
  end
end