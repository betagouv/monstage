# frozen_string_literal: true

require 'application_system_test_case'

module Product
  class InternshipOfferStepperTest < ApplicationSystemTestCase
    include OrganisationFormFiller
    include InternshipOfferInfoFormFiller
    include TutorFormFiller

    test 'USE_W3C, new_dashboard_stepper_organisation_path' do
      employer = create(:employer)
      group = create(:group, name: 'hello', is_public: true)

      sign_in(employer)
      run_request_and_cache_response(report_as: 'new_dashboard_stepper_organisation_path') do
        visit new_dashboard_stepper_organisation_path
        fill_in_organisation_form(is_public: true, group: group)
      end
    end

    test 'USE_W3C, new_dashboard_stepper_internship_offer_info_path' do
      employer = create(:employer)
      organisation = create(:organisation, employer: employer)
      sector = create(:sector)
      available_weeks = [Week.find_by(number: 10, year: 2019), Week.find_by(number: 11, year: 2019)]
      sign_in(employer)

      travel_to(Date.new(2019, 3, 1)) do
        run_request_and_cache_response(report_as: 'new_dashboard_stepper_internship_offer_info_path') do
          visit new_dashboard_stepper_internship_offer_info_path(organisation_id: organisation.id)
          fill_in_internship_offer_info_form(sector: sector,
                                             weeks: available_weeks)
        end
      end
    end

    test 'USE_W3C, new_dashboard_stepper_tutor_path' do
      employer = create(:employer)
      sign_in(employer)
      organisation = create(:organisation, employer: employer)
      internship_offer_info = create(:internship_offer_info,  employer: employer)

      run_request_and_cache_response(report_as: 'new_dashboard_stepper_tutor_path') do
        visit new_dashboard_stepper_tutor_path(organisation_id: organisation.id,
                                                 internship_offer_info_id: internship_offer_info.id)
        fill_in_tutor_form
      end
    end
  end
end
