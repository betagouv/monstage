require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase
  test 'number of departments' do
    assert_equal 101, Department::MAP.keys.size
  end
end
