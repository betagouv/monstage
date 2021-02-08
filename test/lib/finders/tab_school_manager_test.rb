# frozen_string_literal: true

require 'test_helper'

module Finders
  class TabSchoolManagerTest < ActiveSupport::TestCase
    test 'pending_agreements_count only count 3e generale applications' do
      school = create(:school, :with_school_manager)
      student_1 = create(:student, school: school)
      student_2 = create(:student, school: school)

      draft_internship_application = create(:weekly_internship_application,
                                               :approved,
                                               student: student_1)
      approved_internship_application = create(:free_date_internship_application,
                                               :approved,
                                               student: student_2)
      school_tab = TabSchoolManager.new(school: school)
      assert_equal 1, school_tab.pending_agreements_count
    end

    test 'pending_agreements_count include approved and exclude draft applications' do
      school = create(:school, :with_school_manager)
      student = create(:student, school: school)

      draft_internship_application = create(:weekly_internship_application,
                                               :drafted,
                                               student: student)
      approved_internship_application = create(:weekly_internship_application,
                                               :approved,
                                               student: student)
      school_tab = TabSchoolManager.new(school: school)
      assert_equal 1, school_tab.pending_agreements_count
    end

    test 'pending_agreements_count include created agreements but not signed by school_manager' do
      school = create(:school, :with_school_manager)
      student = create(:student, school: school)

      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      student: student)
      create(:internship_agreement, internship_application: internship_application,
                                    school_manager_accept_terms: false,
                                    employer_accept_terms: true)
      school_tab = TabSchoolManager.new(school: school)
      assert_equal 1, school_tab.pending_agreements_count
    end

    test 'pending_agreements_count ignored created agreements but not signed by other school_manager' do
      school = create(:school, :with_school_manager)
      student = create(:student, school: school)

      internship_application = create(:weekly_internship_application,
                                      :approved)
      create(:internship_agreement, internship_application: internship_application,
                                    school_manager_accept_terms: false,
                                    employer_accept_terms: true)
      school_tab = TabSchoolManager.new(school: school)
      assert_equal 0, school_tab.pending_agreements_count
    end

    test 'pending_agreements_count ignored created agreements signed by himself' do
      school = create(:school, :with_school_manager)
      student = create(:student, school: school)

      internship_application = create(:weekly_internship_application,
                                      :approved,
                                      student: student)
      create(:internship_agreement, internship_application: internship_application,
                                    school_manager_accept_terms: true)
      school_tab = TabSchoolManager.new(school: school)
      assert_equal 0, school_tab.pending_agreements_count
    end
  end
end
