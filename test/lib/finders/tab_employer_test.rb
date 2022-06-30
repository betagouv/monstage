# frozen_string_literal: true

require 'test_helper'

module Finders
  class TabEmployerTest < ActiveSupport::TestCase
    test 'pending_agreements_count only draft agreements' do
      employer = create(:employer)
      internship_offer = create(:weekly_internship_offer,employer: employer, max_candidates: 3, max_students_per_group: 3)
      draft_application = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      completed_application = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      completed_application.internship_agreement.update(aasm_state: :completed_by_employer)

      employer_tab = TabEmployer.new(user: employer)
      assert_equal 1, employer_tab.pending_agreements_count
    end
  end
end