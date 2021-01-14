# frozen_string_literal: true

require 'test_helper'

class SchoolUsersAssociationTest < ActiveSupport::TestCase
  test 'Users included by school' do
    school = create(:school)

    student = create(:student, school: school)
    school_manager = create(:school_manager, school: school)
    main_teacher = create(:main_teacher, school: school)
    teacher = create(:teacher, school: school)

    assert_equal [student], school.students.all
    assert_equal [main_teacher], school.main_teachers.all
    assert_equal [teacher], school.teachers.all
    assert_equal school_manager, school.school_manager
    assert_includes school.users, student
    assert_includes school.users, main_teacher
    assert_includes school.users, teacher
    assert_includes school.users, school_manager
  end

  test 'Users included by api::school' do
    school = create(:school)

    student = create(:student, school: school)
    school_manager = create(:school_manager, school: school)
    main_teacher = create(:main_teacher, school: school)
    teacher = create(:teacher, school: school)

    school = Reporting::School.find(school.id)
    assert_equal [student], school.students.all
    assert_equal [main_teacher], school.main_teachers.all
    assert_equal [teacher], school.teachers.all
    assert_equal school_manager, school.school_manager
    assert_includes school.users, student
    assert_includes school.users, main_teacher
    assert_includes school.users, teacher
    assert_includes school.users, school_manager
  end
end
