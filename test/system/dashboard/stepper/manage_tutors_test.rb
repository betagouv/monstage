# frozen_string_literal: true

require 'application_system_test_case'

class ManageTutorsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include TutorFormFiller

  def wait_form_submitted
    find('.alert-sticky')
  end

  test 'can create "3e generale" InternshipOffer' do
    employer = create(:employer)
    sign_in(employer)
    organisation = create(:organisation, creator_id: employer.id)
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
    assert_equal 'troisieme_generale', InternshipOffer.last.school_track
  end

  test 'can create "3e segpa" InternshipOffer' do
    employer = create(:employer)
    sign_in(employer)
    organisation = create(:organisation, creator: employer)
    internship_offer_info = create(:troisieme_segpa_internship_offer_info, employer: employer)
    assert_difference 'InternshipOffer.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit new_dashboard_stepper_tutor_path(organisation_id: organisation.id,
                                               internship_offer_info_id: internship_offer_info.id)
        fill_in_tutor_form
        click_on "Publier l'offre !"
        wait_form_submitted
      end
    end
    assert_equal employer, InternshipOffer.first.employer
    assert_equal 'User', InternshipOffer.first.employer_type
    assert_equal 'troisieme_segpa', InternshipOffer.last.school_track
  end

  test 'as Employer, I can forget my tutor\'s phone and add it afterwards' do
    employer = create(:employer)
    organisation = create(:organisation, creator: employer)
    sign_in(employer)
    internship_offer_info = create(:troisieme_segpa_internship_offer_info, employer: employer)
    assert_no_difference 'InternshipOffer.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit new_dashboard_stepper_tutor_path(organisation_id: organisation.id,
                                               internship_offer_info_id: internship_offer_info.id)
        fill_in 'Nom du tuteur/trice', with: 'Durand'
        fill_in 'Prénom du tuteur/trice', with: 'Brice'
        fill_in 'Adresse électronique / Email', with: 'le@brice.durand'
        fill_in 'Numéro de mobile', with: ' ' # there is the error
        click_on "Publier l'offre !"
        # wait_form_submitted
        find(
          '.alert ul li label',
          text: 'Veuillez saisir un numéro de téléphone pour le tuteur'
        )
      end
    end
    new_phone_number = '+330625441145'
    assert_difference 'InternshipOffer.count' do
      travel_to(Date.new(2019, 3, 1)) do
        visit new_dashboard_stepper_tutor_path(organisation_id: organisation.id,
                                               internship_offer_info_id: internship_offer_info.id)
        fill_in 'Numéro de mobile', with: new_phone_number
        click_on "Publier l'offre !"
        # TO DO : wait_form_submitted 
      end
    end
    assert_equal new_phone_number, Users::Tutor.last.phone, 'Tutor s phone number is not updated'
  end
end
