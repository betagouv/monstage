# frozen_string_literal: true

require 'test_helper'

module Dashboard::InternshipOffers
  class IndexTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #edit as employer owning application student school renders success' do
      school = create(:school, :with_school_manager)
      internship_application = create(:weekly_internship_application, :approved)
      internship_application.student.update(school_id: school.id)
      internship_agreement = create(:internship_agreement, internship_application: internship_application, school_manager_accept_terms: true)
      sign_in(internship_application.internship_offer.employer)

      get dashboard_internship_agreements_path
      assert_select("td[data-head='#{internship_application.internship_offer.title}']")
      assert_response :success
    end

    test 'GET #edit as employer when missing school_manager renders success but missing internship_agreements' do
      school = create(:school) #no_school_manager
      internship_application = create(:weekly_internship_application, :approved)
      internship_application.student.update(school_id: school.id)
      internship_agreement = create(:internship_agreement, internship_application: internship_application, school_manager_accept_terms: true)
      sign_in(internship_application.internship_offer.employer)

      get dashboard_internship_agreements_path
      assert_response :success
      assert_select("h4.fr-h4", text: 'Aucune convention de stage ne requiert votre attention pour le moment.')
    end

    test 'GET #index as teacher ' do
      school = create(:school, :with_school_manager)
      teacher = create(:teacher, school: school)
      internship_application = create(:weekly_internship_application, :approved)
      internship_application.student.update(school_id: school.id)
      internship_agreement = create(:internship_agreement, internship_application: internship_application, school_manager_accept_terms: true)

      sign_in(teacher)

      get dashboard_internship_agreements_path
      assert_response :success
      assert_select("td[data-head='#{internship_application.internship_offer.title}']")
    end

    test 'GET #index as admin_officer ' do
      school = create(:school, :with_school_manager)
      teacher = create(:admin_officer, school: school)
      internship_application = create(:weekly_internship_application, :approved)
      internship_application.student.update(school_id: school.id)
      internship_agreement = create(:internship_agreement, internship_application: internship_application, school_manager_accept_terms: true)

      sign_in(teacher)

      get dashboard_internship_agreements_path
      assert_response :success
      assert_select("td[data-head='#{internship_application.internship_offer.title}']")
    end
    
    test 'GET #index as cpe ' do
      school = create(:school, :with_school_manager)
      cpe = create(:cpe, school: school)
      internship_application = create(:weekly_internship_application, :approved)
      internship_application.student.update(school_id: school.id)
      internship_agreement = create(:internship_agreement, internship_application: internship_application, school_manager_accept_terms: true)

      sign_in(cpe)

      get dashboard_internship_agreements_path
      assert_response :success
      assert_select("td[data-head='#{internship_application.internship_offer.title}']")
    end
  end
end
