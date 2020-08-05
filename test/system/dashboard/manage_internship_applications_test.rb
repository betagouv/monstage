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
                     convention_signed].freeze
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

    test 'weekly_internship_applications internship offers in show view can be filtered' do
      student_1, student_2 = [ create(:student), create(:student) ]
      week_1, week_2 = Week.where(year: Time.now.year)
                           .order(number: :asc)
                           .limit(2)
                           .to_a

      internship_offer = create(
        :weekly_internship_offer,
        weeks: [week_1, week_2],
        employer: @employer,
        max_candidates: 2
      )
      internship_offer_week_1 = create(
        :internship_offer_week,
        week: week_1,
        internship_offer: internship_offer
      )
      internship_offer_week_2 = create(
        :internship_offer_week,
        week: week_2,
        internship_offer: internship_offer
      )

      early_application_for_week_2 = create(
        :weekly_internship_application,
        aasm_state: :submitted,
        submitted_at: 3.days.ago,
        internship_offer_week: internship_offer_week_2,
        student: student_2
      )

      late_application_for_week_1 = create(
        :weekly_internship_application,
        aasm_state: :submitted,
        submitted_at: 2.days.ago,
        internship_offer_week: internship_offer_week_1,
        student: student_1
      )
      sign_in(@employer)

      visit dashboard_internship_offer_internship_applications_path(internship_offer.id)
      find "div[data-test-id=\"internship-application-#{early_application_for_week_2.id}\"]", count: 1
      find "div[data-test-id=\"internship-application-#{late_application_for_week_1.id}\"]", count: 1
      within(".bg-light.row") do
        find "div[data-test-id=\"internship-application-#{early_application_for_week_2.id}\"]", count: 1
      end

      click_on('dates de stage')
      if week_1.id < week_2. id # normal case
        within(".bg-light.row") do
          find "div[data-test-id=\"internship-application-#{late_application_for_week_1.id}\"]", count: 1
        end
      else # might happen with fixture random order creation
        within(".bg-light.row") do
          find "div[data-test-id=\"internship-application-#{early_application_for_week_2.id}\"]", count: 1
        end
      end

      click_on('dates de candidature')
      within(".bg-light.row") do
        find "div[data-test-id=\"internship-application-#{early_application_for_week_2.id}\"]", count: 1
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
