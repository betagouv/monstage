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
    organisation = create(:organisation, employer: employer)
    internship_offer_info = create(:weekly_internship_offer_info,  employer: employer)
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
    assert_equal 'troisieme_generale', InternshipOffer.last.school_track
  end

  test 'can create "3e segpa" InternshipOffer' do
    employer = create(:employer)
    sign_in(employer)
    organisation = create(:organisation, employer: employer)
    internship_offer_info = create(:bac_pro_internship_offer_info, employer: employer)
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
    assert_equal 'bac_pro', InternshipOffer.last.school_track
  end
end
