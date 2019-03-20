require 'test_helper'

class SchoolTest < ActiveSupport::TestCase
  test "coordinates" do
    school = School.new
    assert school.invalid?
    assert_not_empty school.errors[:coordinates]
  end

  test "Users associations" do
    school = create(:school)

    student = create(:student, school: school)
    school_manager = create(:school_manager, school: school)
    main_teacher = create(:main_teacher, school: school)
    teacher = create(:teacher, school: school)

    assert_equal [student], school.students.all
    assert_equal [main_teacher], school.main_teachers.all
    assert_equal [teacher], school.teachers.all
    assert_equal school_manager, school.school_manager
  end
end
