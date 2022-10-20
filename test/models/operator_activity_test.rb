require "test_helper"

class OperatorActivityTest < ActiveSupport::TestCase
  test 'factory should create user activity' do
    assert build(:operator_activity).valid?
  end
end
