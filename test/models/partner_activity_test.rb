require "test_helper"

class PartnerActivityTest < ActiveSupport::TestCase
  test 'factory should create user activity' do
    assert build(:partner_activity).valid?
  end
end
