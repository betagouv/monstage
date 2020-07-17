
require 'application_system_test_case'

module Dashboard
  class AutocompleteSchoolTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    AASM_STATES = %i[submitted
                     expired
                     approved
                     rejected
                     canceled_by_employer
                     canceled_by_student
                     convention_signed]
    setup do
      @employer = create(:employer)
    end

    test 'list/filter internship offers ' do
      weekly_internship_applications = AASM_STATES.map do |state|
        create(:weekly_internship_application,
               state,
               internship_offer: create(:weekly_internship_offer,
                                        employer: @employer))
      end
      free_date_internship_applications = AASM_STATES.map do |state|
        create(:free_date_internship_application,
               state,
               internship_offer: create(:free_date_internship_offer,
                                        employer: @employer))
      end

      sign_in(@employer)
      visit dashboard_internship_offers_path

      [].concat(weekly_internship_applications,
                free_date_internship_applications)
        .map do |internship_application|
        internship_offer = internship_application.internship_offer
        find(".test-internship-offer-#{internship_offer.id}", count: 1)
      end
    end

    test 'show weekly_internship_applications internship offers' do
      weekly_internship_application = create(:weekly_internship_application,
                                             :submitted,
                                             internship_offer: create(:weekly_internship_offer, employer: @employer))
      sign_in(@employer)

      visit dashboard_internship_offer_internship_applications_path(weekly_internship_application.internship_offer)
      find "div[data-test-id=\"internship-application-#{weekly_internship_application.id}\"]", count: 1
      click_on 'Accepter'
      assert_changes -> { weekly_internship_application.reload.approved? },
                    from: false,
                    to: true do
        click_on 'Confirmer'
        find '#alert-text', text: 'Candidature mise à jour avec succès'
      end
    end

    test 'show free_date_internship_applications internship offers' do
      free_date_internship_application = create(:free_date_internship_application,
                                                :submitted,
                                                internship_offer: create(:free_date_internship_offer, employer: @employer))
      sign_in(@employer)

      visit dashboard_internship_offer_internship_applications_path(free_date_internship_application.internship_offer)
      find "div[data-test-id=\"internship-application-#{free_date_internship_application.id}\"]", count: 1
      click_on 'Refuser'
      assert_changes -> { free_date_internship_application.reload.rejected? },
                    from: false,
                    to: true do
        click_on 'Confirmer'
        find '#alert-text', text: 'Candidature mise à jour avec succès'
      end
    end
  end
end
