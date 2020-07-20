# frozen_string_literal: true

require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase
  test 'number of departments (with synonyms)' do
    assert_equal 105, Department::MAP.keys.size
  end

  test '.to_select only include uniq results' do
    assert_equal 1, Department.to_select.map { |option| option[1] }.grep(/Corse-du-Sud/).size
  end

  test '.to_select is sorted by alnum' do
    assert_equal '01 - Ain', Department.to_select.first[0]
    assert_equal '976 - Mayotte', Department.to_select.last[0]
  end
end
