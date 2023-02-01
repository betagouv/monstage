# frozen_string_literal: true

require 'application_system_test_case'

class ManageTutorsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include TutorFormFiller
  include StubsForApiGouvRequests

  setup do
    stub_gouv_api_requests
  end

  def wait_form_submitted
    find('.alert-sticky')
  end

  test 'can create "3e generale" InternshipOffer' do
    employer = create(:employer)
    sign_in(employer)
    organisation = create(:organisation, employer: employer)
    internship_offer_info = create(:weekly_internship_offer_info,  employer: employer)
    assert_difference 'InternshipOffer.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit new_dashboard_stepper_tutor_path(organisation_id: organisation.id,
                                               internship_offer_info_id: internship_offer_info.id)
        page.assert_no_selector('span.number', text: '1')
        page.assert_no_selector('span.number', text: '2')
        find('span.number', text: '3')
        fill_in_tutor_form
        click_on "Publier l'offre !"
        wait_form_submitted
      end
    end
    assert_equal employer, InternshipOffer.first.employer
    assert_equal 'User', InternshipOffer.first.employer_type
  end

  test 'as Employer, I can forget my tutor\'s phone and add it afterwards' do
    employer = create(:employer)
    organisation = create(:organisation, employer: employer)
    sign_in(employer)
    internship_offer_info = create(:weekly_internship_offer_info, employer: employer)
    assert_no_difference 'InternshipOffer.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit new_dashboard_stepper_tutor_path(organisation_id: organisation.id,
                                               internship_offer_info_id: internship_offer_info.id)
        fill_in 'Nom du tuteur/trice', with: 'Brice Durand'
        fill_in 'Adresse électronique / Email', with: 'le@brice.durand'
        fill_in 'Numéro de téléphone', with: ' ' # there is the error
        fill_in "Fonction du tuteur dans l'entreprise", with: 'ministre délégué'
        click_on "Publier l'offre !"
        # wait_form_submitted
        find(
          '.alert ul li label',
          text: 'Veuillez saisir le numéro de téléphone du tuteur de l\'offre de stage'
        )
      end
    end
    new_phone_number = '+330625441145'
    assert_difference 'InternshipOffer.count' do
      travel_to(Date.new(2019, 3, 1)) do
        fill_in 'Numéro de téléphone', with: new_phone_number
        click_on "Publier l'offre !"
      end
    end
    assert_equal new_phone_number, Tutor.last.tutor_phone, 'Tutor s phone number is not updated'
  end

  # EDIT

  test 'can edit tutor' do
    employer        = create(:employer)
    sector          = create(:sector)
    available_weeks = [Week.find_by(number: 10, year: 2023), Week.find_by(number: 11, year: 2023)]
    organisation    = create(:organisation, employer: employer)
    tutor           = create(:tutor)
    internship_offer_info = create(:weekly_internship_offer_info,
                                    employer: employer,
                                    weeks: available_weeks)
    internship_offer = create(:weekly_internship_offer,
                              organisation: organisation,
                              internship_offer_info: internship_offer_info,
                              tutor: tutor,
                              school: internship_offer_info.school,
                              weeks: available_weeks,
                              employer: employer)
    sign_in(employer)
    visit edit_dashboard_internship_offer_path(internship_offer)
    find('button#tabpanel-tutor').click
    fill_in 'Nom du tuteur/trice', with: 'Brice Durand'
    fill_in "Fonction du tuteur dans l'entreprise", with: 'ministre délégué'
    fill_in 'Adresse électronique / Email', with: 'brice@yahoo.com'
    fill_in 'Numéro de téléphone', with: '+330625441145'
    find('input[type="submit"]').click
    find('div.alert.alert-success', text: 'Les modifications sont enregistrées')

    internship_offer.reload
    tutor.reload

    assert_equal 'Brice Durand', tutor.tutor_name
    assert_equal 'ministre délégué', tutor.tutor_role
    assert_equal 'brice@yahoo.com', tutor.tutor_email
    assert_equal '+330625441145', tutor.tutor_phone
    assert_equal 'Brice Durand', internship_offer.tutor_name
    assert_equal 'ministre délégué', internship_offer.tutor_role
    assert_equal 'brice@yahoo.com', internship_offer.tutor_email
    assert_equal '+330625441145', internship_offer.tutor_phone
    within('.container-monstage') do
      find('h1.h2', text: 'Modifier une offre de stage')
    end
  end

  test 'fails gracefully when edit tutor' do
    # Interface does not allow errorring...
  end
end
