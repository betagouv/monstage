# frozen_string_literal: true

require 'test_helper'

class NavbarTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @school = create(:school, :with_school_manager)
  end

  test 'employer' do
    employer = create(:employer)
    sign_in(employer)
    get employer.custom_dashboard_path
    assert_select("li a.fr-link[href=\"#{root_path}\"]", count: 1, text: 'Accueil')
    assert_select('li a.fr-link.text-decoration-none.active', count: 1)
    assert_select('li a.fr-link.text-decoration-none.active', text: employer.dashboard_name, count: 1)
  end

  test 'main_teacher' do
    main_teacher = create(:main_teacher,
                          school: @school,
                          class_room: create(:class_room, school: @school))
    sign_in(main_teacher)
    get main_teacher.custom_dashboard_path
    assert_select(
      'li a.fr-link[href=?]',
      main_teacher.presenter.default_internship_offers_path
    )
    assert_select("li a.fr-link.text-decoration-none[href=\"#{root_path}\"]", count: 0, text: 'Accueil')
    assert_select('li a.fr-link.text-decoration-none.active', count: 1)
    assert_select('li a.fr-link.text-decoration-none.active', text: 'Ma classe',
                                      count: 1)
  end

  test 'other' do
    other = create(:other, school: @school)
    sign_in(other)
    get other.custom_dashboard_path
    assert_select(
      'li a.fr-link[href=?]',
      Presenters::User.new(other).default_internship_offers_path
    )
    assert_select("li a.fr-link.text-decoration-none[href=\"#{root_path}\"]", count: 0, text: 'Accueil')
    assert_select('li a.fr-link.text-decoration-none.active', count: 1)
    assert_select('li a.fr-link.text-decoration-none.active', text: 'Mon établissement', count: 1)
  end

  test 'operator' do
    operator = create(:user_operator)
    sign_in(operator)
    get operator.custom_dashboard_path
    # assert_select("li a.fr-link[href=\"#{reporting_dashboards_path(school_year: SchoolYear::Current.new.beginning_of_period.year, subscribed_school: false)}\"]",
    #               count: 1,
    #               text: 'Statistiques')
    assert_select('li a.fr-link.text-decoration-none.active', count: 1)
    assert_select('li a.fr-link.text-decoration-none.active', text: operator.dashboard_name,
                                      count: 1)
  end

  test 'school_manager' do
    school_manager = @school.school_manager
    sign_in(school_manager)
    get school_manager.custom_dashboard_path
    assert_select(
      'li a.fr-link[href=?]',
      school_manager.presenter.default_internship_offers_path
    )
    assert_select('li a.fr-link.text-decoration-none.active', count: 1)
    assert_select('li a.fr-link.text-decoration-none.active', text: 'Mon établissement', count: 1)
  end

  test 'student' do
    student = create(:student)
    sign_in(student)
    get student.custom_dashboard_path
    assert_select(
      'li a.fr-link[href=?]',
      student.presenter.default_internship_offers_path
    )
    assert_select('li a.fr-link.text-decoration-none.active', count: 1)
    assert_select('li a.fr-link.text-decoration-none.active', text: student.dashboard_name, count: 1)
  end

  test 'teacher' do
    teacher = create(:teacher, school: @school,
                               class_room: create(:class_room, school: @school))
    sign_in(teacher)
    get teacher.custom_dashboard_path
    assert_select(
      'li a.fr-link[href=?]',
      teacher.presenter.default_internship_offers_path
    )
    assert_select('li a.fr-link.text-decoration-none.active', count: 1)
    assert_select('li a.fr-link.text-decoration-none.active', text: 'Ma classe',
                                      count: 1)
  end

  test 'statistician' do
    statistician = create(:statistician)
    sign_in(statistician)
    get statistician.custom_dashboard_path
    assert_select('li a.fr-link.text-decoration-none.active', count: 1, text: 'Statistiques')
    assert_select('li a.fr-link.text-decoration-none.active', text: statistician.dashboard_name,
                                      count: 1)
  end
end
