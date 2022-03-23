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
      find('a.btn-link', text: 'Tout afficher +', exact_text: true)
      find('button', text: 'Accepter').click
      # click_on 'Accepter'
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
        max_candidates: 2,
        max_students_per_group: 1
      )

      early_application_for_week_2 = create(
        :weekly_internship_application,
        aasm_state: :submitted,
        submitted_at: 3.days.ago,
        week: week_2,
        student: student_2,
        internship_offer: internship_offer
      )

      late_application_for_week_1 = create(
        :weekly_internship_application,
        aasm_state: :submitted,
        submitted_at: 2.days.ago,
        week: week_1,
        student: student_1,
        internship_offer: internship_offer
      )
      sign_in(@employer)

      visit dashboard_internship_offer_internship_applications_path(internship_offer.id)
      find "div[data-test-id=\"internship-application-#{early_application_for_week_2.id}\"]", count: 1
      find "div[data-test-id=\"internship-application-#{late_application_for_week_1.id}\"]", count: 1
      find "div[data-test-id=\"internship-application-#{early_application_for_week_2.id}\"]", count: 1

      select('par dates de stage')
      if week_1.id < week_2. id # normal case
        find "div[data-test-id=\"internship-application-#{late_application_for_week_1.id}\"]", count: 1
      else # might happen with fixture random order creation
        find "div[data-test-id=\"internship-application-#{early_application_for_week_2.id}\"]", count: 1
      end

      select('par dates de candidatures')
      find "div[data-test-id=\"internship-application-#{early_application_for_week_2.id}\"]", count: 1

      click_link(internship_offer.title)
      find('div.h3', text: internship_offer.title, exact_text: true)
    end

    test 'weekly_internship_applications show student details anyway' do
      student_1 = create(:student)
      week_1_ar = Week.where(year: Time.now.year)
                      .order(number: :asc)
                      .limit(1)
                      .to_a

      internship_offer = create(
        :weekly_internship_offer,
        weeks: week_1_ar,
        employer: @employer
      )

      application_for_week_1 = create(
        :weekly_internship_application,
        aasm_state: :submitted,
        submitted_at: 3.days.ago,
        week: internship_offer.weeks.first,
        internship_offer: internship_offer,
        student: student_1
      )

      sign_in(@employer)

      visit dashboard_internship_offer_internship_applications_path(internship_offer.id)
      find "div[data-test-id=\"internship-application-#{application_for_week_1.id}\"]", count: 1

      find("div[data-test-id=\"internship-application-#{application_for_week_1.id}\"]  button", text: 'Accepter').click
      click_button('Confirmer')
      click_link('Tout afficher +')
      find('.student-name', text: "#{student_1.first_name} #{student_1.last_name}")
      find('.student-email', text: student_1.email)

    end

    test 'show free_date_internship_applications internship offers' do
      free_date_internship_application = create(:free_date_internship_application,
                                                :submitted,
                                                internship_offer: create(:free_date_internship_offer, employer: @employer))
      sign_in(@employer)

      visit dashboard_internship_offer_internship_applications_path(free_date_internship_application.internship_offer)
      find "div[data-test-id=\"internship-application-#{free_date_internship_application.id}\"]", count: 1
      find('button.fr-fi-close-line').click
      assert_changes -> { free_date_internship_application.reload.rejected? },
                     from: false,
                     to: true do
        click_on 'Confirmer'
        find '#alert-text', text: 'Candidature mise à jour avec succès'
      end
    end
  end
end
