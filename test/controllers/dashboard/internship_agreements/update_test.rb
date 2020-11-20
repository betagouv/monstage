# frozen_string_literal: true

require 'test_helper'

module Dashboard::InternshipAgreements
  class UpdateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'PATCH #update as visitor redirects to new_user_session_path' do
      internship_agreement = create(:internship_agreement, employer_accept_terms: true)
      patch dashboard_internship_agreement_path(internship_agreement.id),
            params: { internship_agreement: {school_representative_full_name: 'poupinet'} }
      assert_redirected_to new_user_session_path
    end

    # As Employer
    test 'PATCH #update as employer not owning internship_offer redirects to root path' do
      internship_offer = create(:weekly_internship_offer)
      internship_agreement = create(:internship_agreement, employer_accept_terms: true)
      sign_in(create(:employer))
      patch dashboard_internship_agreement_path(internship_agreement.id),
            params: { internship_agreement: {school_representative_full_name: 'poupinet'} }
      assert_redirected_to root_path
    end

    test 'PATCH #update as employer owning internship_offer updates internship_agreement' do
      internship_application = create(:weekly_internship_application, :approved)
      internship_agreement = create(:internship_agreement, employer_accept_terms: true, internship_application: internship_application)
      new_organisation_representative_full_name = 'John Doe'
      params = {
        'internship_agreement' => {
          organisation_representative_full_name: new_organisation_representative_full_name
        }
      }
      sign_in(internship_application.internship_offer.employer)

      patch dashboard_internship_agreement_path(internship_agreement.id, params)

      assert_redirected_to(dashboard_internship_agreement_path(internship_agreement),
                           'redirection should point to updated agreement')
      assert_equal(new_organisation_representative_full_name,
                  internship_agreement.reload.organisation_representative_full_name,
                  'can\'t update internship_agreement organisation representative full name')
    end

    # As School Manager
    test 'PATCH #update as school manager not owning student redirects to user_session_path' do
      internship_offer = create(:weekly_internship_offer)
      internship_agreement = create(:internship_agreement, employer_accept_terms: true)
      sign_in(create(:school_manager))
      patch dashboard_internship_agreement_path(internship_agreement.id),
            params: { internship_agreement: {school_representative_full_name: 'poupinet'} }
      assert_redirected_to root_path
    end

    test 'PATCH #update as school manage owning students updates internship_agreement' do
      internship_application = create(:weekly_internship_application, :approved)
      internship_agreement = create(:internship_agreement, employer_accept_terms: true, internship_application: internship_application)
      new_school_representative_full_name = 'John Doe'
      params = {
        'internship_agreement' => {
          school_representative_full_name: new_school_representative_full_name
        }
      }
      sign_in(internship_application.student.school.school_manager)

      patch dashboard_internship_agreement_path(internship_agreement.id, params)

      assert_redirected_to(dashboard_internship_agreement_path(internship_agreement),
                           'redirection should point to updated agreement')
      assert_equal(new_school_representative_full_name,
                  internship_agreement.reload.school_representative_full_name,
                  'can\'t update internship_agreement school representative full name')
    end
  end
end
