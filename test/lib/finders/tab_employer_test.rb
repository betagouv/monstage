# frozen_string_literal: true

require 'test_helper'

module Finders
  include TeamAndAreasHelper
  class TabEmployerTest < ActiveSupport::TestCase
    test 'pending_agreements_count only draft agreements' do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer, employer: employer, max_students_per_group: 2, max_candidates: 2)
      draft_application = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      completed_application = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      completed_application.internship_agreement.update(aasm_state: :completed_by_employer)

      employer_tab = TabEmployer.new(user: employer)
      assert_equal 1, employer_tab.pending_agreements_count
    end

    test '.pending_internship_applications_actions_count' do
      employer = create(:employer)
      InternshipApplication.aasm.states.each do |state|
        student = create(:student)
        wio = create(:weekly_internship_offer,
                     employer: employer,
                     internship_offer_area: employer.current_area)
        create(
          :weekly_internship_application,
          aasm_state: state.name.to_sym,
          internship_offer: wio,
          student: student
        )
      end
      tab_value = TabEmployer.new(user: employer)
                             .pending_internship_applications_actions_count
      # 1 for :read_by_employer,
      # 1 for :submitted,
      # 1 for :examined
      assert_equal 3, tab_value
    end

    test '.pending_agreements_actions_count with 1 signature by employer' do
      employer         = create(:employer)
      internship_offer = create(:weekly_internship_offer, employer: employer)
      status_count = InternshipAgreement.aasm.states.count
      status_count.times do
        student = create(:student)
        wio = create(:weekly_internship_offer, employer: employer)
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
        signatory_role: 'employer',
        internship_agreement_id: InternshipAgreement.find_by(aasm_state: :signatures_started).id
      )
      tab_value = TabEmployer.new(user: employer).pending_agreements_actions_count
      assert_equal 3, tab_value
      # 1 for :draft
      # 1 for :started_by_employer
      # 1 for :validated
      # 0 for :signatures_started
    end

    test '.pending_agreements_actions_count without signature by employer' do
      employer         = create(:employer)
      internship_offer = create(:weekly_internship_offer, employer: employer)
      status_count = InternshipAgreement.aasm.states.count
      status_count.times do
        student = create(:student)
        wio = create(:weekly_internship_offer, employer: employer)
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
        signatory_role: 'school_manager',
        internship_agreement_id: InternshipAgreement.find_by(aasm_state: :signatures_started).id
      )
      tab_value = TabEmployer.new(user: employer).pending_agreements_actions_count
      assert_equal 4, tab_value
      # 1 for :draft
      # 1 for :started_by_employer
      # 1 for :validated
      # 1 for :signatures_started
    end


  end
end
