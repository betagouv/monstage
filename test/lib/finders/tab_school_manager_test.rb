# frozen_string_literal: true

require 'test_helper'

module Finders
  class TabSchoolManagerTest < ActiveSupport::TestCase
    test 'pending_agreements_count only count completed by employer agreements' do
      school = create(:school, :with_school_manager)
      student_1 = create(:student, school: school)
      student_2 = create(:student, school: school)

      internship_application_1 = create(:weekly_internship_application,
                                               :approved,
                                               student: student_1)
      internship_application_2 = create(:weekly_internship_application,
                                               :approved,
                                               student: student_2)
      internship_application_2.internship_agreement.update(aasm_state: :completed_by_employer)
      school_tab = TabSchoolManager.new(school: school)
      assert_equal 1, school_tab.pending_agreements_count
    end
  end
end
