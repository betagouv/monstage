# frozen_string_literal: true

require 'application_system_test_case'

class NavbarTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @school = create(:school, :with_school_manager)
  end

  test "employer" do
    employer = create(:employer)
    sign_in(employer)
    visit employer.custom_dashboard_path
    assert_selector(".navbar a.active", count: 1)
    assert_selector(".navbar a.active", text: employer.dashboard_name,
                                        count: 1)
  end

  test "main_teacher" do
    main_teacher = create(:main_teacher, school: @school,
                                         class_room: create(:class_room, school: @school))
    sign_in(main_teacher)
    visit main_teacher.custom_dashboard_path
    assert_selector(".navbar a.active", count: 1)
    assert_selector(".navbar a.active", text: main_teacher.dashboard_name,
                                        count: 1)
  end

  test "other" do
    other = create(:other, school: @school)
    sign_in(other)
    visit other.custom_dashboard_path
    assert_selector(".navbar a.active", count: 1)
    assert_selector(".navbar a.active", text: other.dashboard_name,
                                        count: 1)
  end

  test "operator" do
    operator = create(:user_operator)
    sign_in(operator)
    visit operator.custom_dashboard_path
    assert_selector(".navbar a.active", count: 1)
    assert_selector(".navbar a.active", text: operator.dashboard_name,
                                        count: 1)
  end

  test "school_manager" do
    school_manager = @school.school_manager
    sign_in(school_manager)
    visit school_manager.custom_dashboard_path
    assert_selector(".navbar a.active", count: 1)
    assert_selector(".navbar a.active", text: school_manager.dashboard_name,
                                        count: 1)
  end

  test "student" do
    student = create(:student)
    sign_in(student)
    visit student.custom_dashboard_path
    assert_selector(".navbar a.active", count: 1)
    assert_selector(".navbar a.active", text: student.dashboard_name,
                                        count: 1)
  end

  test "teacher" do
    teacher = create(:teacher, school: @school,
                               class_room: create(:class_room, school: @school))
    sign_in(teacher)
    visit teacher.custom_dashboard_path
    assert_selector(".navbar a.active", count: 1)
    assert_selector(".navbar a.active", text: teacher.dashboard_name,
                                        count: 1)
  end
end
