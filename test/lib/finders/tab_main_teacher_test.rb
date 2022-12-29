# frozen_string_literal: true

require 'test_helper'

module Finders
  class TabMainTeacherTest < ActiveSupport::TestCase
    # test 'pending_agreements_count only count 3e generale applications' do
    #   school = create(:school, :with_school_manager)
    #   class_room = create(:class_room, school: school)
    #   main_teacher = create(:main_teacher, school: school, class_room: class_room)
    #   student_1 = create(:student, school: school, class_room: class_room)
    #   student_2 = create(:student, school: school, class_room: class_room)

    #   approved_internship_application = create(:weekly_internship_application,
    #                                            :approved,
    #                                            student: student_2)
    #   tab_main_teacher = TabMainTeacher.new(main_teacher: main_teacher)
    #   assert_equal 1, tab_main_teacher.pending_agreements_count
    # end

    # test 'pending_agreements_count include approved and exclude draft applications' do
    #   school = create(:school, :with_school_manager)
    #   class_room = create(:class_room, school: school)
    #   main_teacher = create(:main_teacher, school: school, class_room: class_room)
    #   student = create(:student, school: school, class_room: class_room)

    #   draft_internship_application = create(:weekly_internship_application,
    #                                            :drafted,
    #                                            student: student)
    #   approved_internship_application = create(:weekly_internship_application,
    #                                            :approved,
    #                                            student: student)
    #   tab_main_teacher = TabMainTeacher.new(main_teacher: main_teacher)
    #   assert_equal 1, tab_main_teacher.pending_agreements_count
    # end

    # test 'pending_agreements_count include created agreements but not signed by main_teacher' do
    #   school = create(:school, :with_school_manager)
    #   class_room = create(:class_room, school: school)
    #   main_teacher = create(:main_teacher, school: school, class_room: class_room)
    #   student = create(:student, school: school, class_room: class_room)

    #   internship_application = create(:weekly_internship_application,
    #                                   :approved,
    #                                   student: student)
    #   create(:internship_agreement, internship_application: internship_application,
    #                                 main_teacher_accept_terms: false,
    #                                 employer_accept_terms: true)
    #   tab_main_teacher = TabMainTeacher.new(main_teacher: main_teacher)
    #   assert_equal 1, tab_main_teacher.pending_agreements_count
    # end

    # test 'pending_agreements_count ignored created agreements but not signed by other main_teacher' do
    #   school = create(:school, :with_school_manager)
    #   class_room = create(:class_room, school: school)
    #   main_teacher = create(:main_teacher, school: school, class_room: class_room)
    #   student = create(:student, school: school, class_room: class_room)

    #   internship_application = create(:weekly_internship_application,
    #                                   :approved)
    #   create(:internship_agreement, internship_application: internship_application,
    #                                 employer_accept_terms: false,
    #                                 main_teacher_accept_terms: true)
    #   tab_main_teacher = TabMainTeacher.new(main_teacher: main_teacher)
    #   assert_equal 0, tab_main_teacher.pending_agreements_count
    # end

    # test 'pending_agreements_count ignored created agreements signed by himself' do
    #   school = create(:school, :with_school_manager)
    #   class_room = create(:class_room, school: school)
    #   main_teacher = create(:main_teacher, school: school, class_room: class_room)
    #   student = create(:student, school: school, class_room: class_room)

    #   internship_application = create(:weekly_internship_application,
    #                                   :approved,
    #                                   student: student)
    #   create(:internship_agreement, internship_application: internship_application,
    #                                 main_teacher_accept_terms: true)
    #   tab_main_teacher = TabMainTeacher.new(main_teacher: main_teacher)
    #   assert_equal 0, tab_main_teacher.pending_agreements_count
    # end
  end
end
