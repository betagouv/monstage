# frozen_string_literal: true

require 'test_helper'

module Finders
  class TabSchoolManagerTest < ActiveSupport::TestCase
    test 'pending_agreements_count only count completed by employer agreements' do
      school = create(:school, :with_school_manager)
      student_1 = create(:student, school: school)
      student_2 = create(:student, school: school)

      internship_application_1 = create(:internship_application,
                                               :approved,
                                               student: student_1)
      internship_application_2 = create(:internship_application,
                                               :approved,
                                               student: student_2)
      internship_application_2.internship_agreement.update(aasm_state: :completed_by_employer)
      school_tab = TabSchoolManager.new(school: school)
      assert_equal 1, school_tab.pending_agreements_count
    end

    test '.pending_agreements_count with 1 signature by school_manager' do
      school           = create(:school, :with_school_manager)
      school_manager   = school.school_manager
      internship_offer = create(:internship_offer)
      status_count     = InternshipAgreement.aasm.states.count
      status_count.times do
        student = create(:student, school: school)
        wio = create(:internship_offer)
        create(
          :weekly_internship_application,
          :submitted,
          internship_offer: wio,
          student: student
        )
      end
      InternshipAgreement.aasm.states.each_with_index do |state, index|
        create(
          :internship_agreement,
          aasm_state: state.name.to_sym,
          internship_application: InternshipApplication.all.to_a[index],
        )
      end
      create(
        :signature,
        signatory_role: 'school_manager', # test specfic case
        internship_agreement_id: InternshipAgreement.find_by(aasm_state: :signatures_started).id
      )
      tab_value = TabSchoolManager.new(school: school).pending_agreements_count
      assert_equal 3, tab_value
      # 1 for :draft
      # 1 for :started_by_employer
      # 1 for :validated
      # 0 for :signatures_started
    end

    test '.pending_agreements_count with 1 signature by employer' do
      school           = create(:school, :with_school_manager)
      school_manager   = school.school_manager
      internship_offer = create(:internship_offer)
      status_count     = InternshipAgreement.aasm.states.count
      status_count.times do
        student = create(:student, school: school)
        wio = create(:internship_offer)
        create(
          :weekly_internship_application,
          :submitted,
          internship_offer: wio,
          student: student
        )
      end
      InternshipAgreement.aasm.states.each_with_index do |state, index|
        create(
          :internship_agreement,
          aasm_state: state.name.to_sym,
          internship_application: InternshipApplication.all.to_a[index],
        )
      end
      create(
        :signature,
        signatory_role: 'employer', # test specfic case
        internship_agreement_id: InternshipAgreement.find_by(aasm_state: :signatures_started).id
      )
      tab_value = TabSchoolManager.new(school: school).pending_agreements_count
      assert_equal 4, tab_value
      # 1 for :draft
      # 1 for :started_by_employer
      # 1 for :validated
      # 1 for :signatures_started
    end
  end
end
