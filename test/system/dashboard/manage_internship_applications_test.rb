require 'application_system_test_case'

module Dashboard
  class AutocompleteSchoolTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    AASM_STATES = %i[submitted
                     expired
                     approved
                     rejected
                     canceled_by_employer
                     canceled_by_student ].freeze
    setup do
      @employer = create(:employer)
    end

    test 'list/filter internship offers ' do
      weekly_internship_applications = AASM_STATES.map do |state|
        create(:weekly_internship_application,
               state,
               internship_offer: create(:weekly_internship_offer, employer: @employer, internship_offer_area_id: @employer.current_area_id))
      end

      sign_in(@employer)
      visit dashboard_internship_offers_path

      weekly_internship_applications.each do |internship_application|
        internship_offer = internship_application.internship_offer
        find(".test-internship-offer-#{internship_offer.id}")
      end
    end
  end
end
