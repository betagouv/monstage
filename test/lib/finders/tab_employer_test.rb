# frozen_string_literal: true

require 'test_helper'

module Finders
  class TabEmployerTest < ActiveSupport::TestCase
    test 'pending_agreements_count only agreements' do
      employer = create(:employer)
      internship_offer = create(:free_date_internship_offer,employer: employer)
      application = create(:free_date_internship_application, :approved, internship_offer: internship_offer)

      draft_internship_agreement = create(:internship_agreement, internship_application: application)
      validated_internship_agreement = create(:internship_agreement, aasm_state: 'validated', internship_application: application)
      employer_tab = TabEmployer.new(user: employer)
      assert_equal 1, employer_tab.pending_agreements_count
    end
  end
end