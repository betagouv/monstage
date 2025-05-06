# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class IndexTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    def assert_has_link_count_to_transition(internship_application, transition, count)
      internship_offer = internship_application.internship_offer
      if count.positive?
        assert_select 'form[action=?]',
                      dashboard_internship_offer_internship_application_path(internship_offer,
                                                                             uuid: internship_application.uuid)
      end
      assert_select "form input[name=\"transition\"][value=\"#{transition}\"]",
                    count: count
    end

    test 'GET internship_applications#index redirects to new_user_session_path when not logged in' do
      get dashboard_internship_offer_internship_applications_path(create(:weekly_internship_offer))
      assert_redirected_to new_user_session_path
    end

    test 'GET #index redirects to root_path when logged in as student' do
      sign_in(create(:student))
      get dashboard_internship_offer_internship_applications_path(create(:weekly_internship_offer))
      assert_redirected_to root_path
    end

    test 'GET #index redirects to root_path when logged as different employer than internship_offer.employer' do
      sign_in(create(:employer))
      get dashboard_internship_offer_internship_applications_path(create(:weekly_internship_offer))
      assert_redirected_to root_path
    end

    test 'GET #index succeed with weekly_internship_application when logged in as employer, shows default fields' do
      school = create(:school, city: 'Paris', name: 'Mon établissement')
      student = create(:student, school: school,
                                 phone: '+330665656565',
                                 email: 'student@edu.school',
                                 birth_date: 14.years.ago,
                                 resume_other: 'resume_other',
                                 resume_languages: 'resume_languages')
      internship_application = create(:weekly_internship_application, :submitted, student: student)
      sign_in(internship_application.internship_offer.employer)
      get dashboard_internship_offer_internship_applications_path(internship_application.internship_offer)
      assert_response :success

      assert_select 'title', 'Mes candidatures | Monstage'
      assert_select '.h4.mb-0', "#{internship_application.student.name}"
      assert_select '.font-weight-bold', "le #{I18n.localize(internship_application.created_at, format: '%d %B')}"
      assert_select '.student-name', student.name
      assert_select '.school-name', school.name
      assert_select '.school-city', school.city
      assert_select '.student-age', "#{student.age} ans"
      assert_select '.student-email', internship_application.student_email
      assert_select '.student-phone', internship_application.student_phone
      assert_select '.reboot-trix-content', student.resume_other.to_plain_text
      assert_select '.reboot-trix-content', student.resume_languages.to_plain_text
    end

    test 'GET #index (sentry#1887730132) succeed with weekly_internship_application when logged in as employer, and student is archived' do
      school = create(:school, city: 'Paris', name: 'Mon établissement')
      student = create(:student, school: school,
                                 phone: '+330665656565',
                                 email: 'student@edu.school',
                                 birth_date: 14.years.ago,
                                 resume_other: 'resume_other',
                                 resume_languages: 'resume_languages')
      internship_application = create(:weekly_internship_application, :submitted, student: student)
      student.archive
      sign_in(internship_application.internship_offer.employer)
      get dashboard_internship_offer_internship_applications_path(internship_application.internship_offer)
      assert_response :success
    end

    test 'GET #index with drafted does not shows internship_application' do
      internship_application = create(:weekly_internship_application, :drafted)
      sign_in(internship_application.internship_offer.employer)
      get dashboard_internship_offer_internship_applications_path(internship_application.internship_offer)
      assert_response :success
      assert_select "[data-test-id=internship-application-#{internship_application.id}]", count: 0
    end

    test 'GET #index with expired shows internship_application' do
      internship_application = create(:weekly_internship_application, :expired)
      sign_in(internship_application.internship_offer.employer)
      get dashboard_internship_offer_internship_applications_path(internship_application.internship_offer)
      assert_response :success
      assert_select "[data-test-id=internship-application-#{internship_application.id}]", count: 1
    end

    test 'GET #index with submitted internship_application, shows employer_validate/reject links' do
      internship_application = create(:weekly_internship_application, :submitted)
      sign_in(internship_application.internship_offer.employer)
      get dashboard_internship_offer_internship_applications_path(internship_application.internship_offer)
      assert_response :success

      assert_select 'a span.text-danger.fr-icon--lg.fr-icon-arrow-down-s-line', 0
      assert_select 'a span.fr-icon-arrow-right-s-line', 1
      assert_select "[data-test-id=internship-application-#{internship_application.id}]", count: 1
      assert_has_link_count_to_transition(internship_application, :employer_validate!, 1)
      assert_has_link_count_to_transition(internship_application, :reject!, 1)
      assert_has_link_count_to_transition(internship_application, :cancel_by_employer!, 0)
      assert_has_link_count_to_transition(internship_application, :signed!, 0)
    end

    test 'GET #index as Employer with approved internship_application, shows cancel_by_employer! & signed! links' do
      internship_application = create(:weekly_internship_application, :validated_by_employer)
      internship_agreement = create(:internship_agreement, internship_application: internship_application)
      sign_in(internship_application.internship_offer.employer)
      get dashboard_internship_offer_internship_applications_path(internship_application.internship_offer)
      assert_response :success

      assert_select 'a span.text-danger.fr-icon--lg.fr-icon-arrow-down-s-line', 1
      assert_select 'a span.fr-icon-arrow-right-s-line', 0
      assert_has_link_count_to_transition(internship_application, :employer_validate!, 0)
      assert_has_link_count_to_transition(internship_application, :reject!, 0)
      assert_has_link_count_to_transition(internship_application, :cancel_by_employer!, 0)
    end

    test 'GET #index with rejected offer, shows approve' do
      internship_application = create(:weekly_internship_application, :rejected)
      sign_in(internship_application.internship_offer.employer)
      get dashboard_internship_offer_internship_applications_path(internship_application.internship_offer)
      assert_response :success
      assert_has_link_count_to_transition(internship_application, :employer_validate!, 1)
      assert_has_link_count_to_transition(internship_application, :reject!, 0)
      assert_has_link_count_to_transition(internship_application, :cancel_by_employer!, 0)
      assert_has_link_count_to_transition(internship_application, :signed!, 0)
    end
  end
end
