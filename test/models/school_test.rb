require 'test_helper'

class SchoolTest < ActiveSupport::TestCase
  test "coordinates" do
    school = School.new
    assert school.invalid?
    assert_not_empty school.errors[:coordinates]
  end
end
