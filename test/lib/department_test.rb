# frozen_string_literal: true

require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase
  test 'number of departments' do
    assert_equal 105, Department::MAP.keys.size
  end
end
