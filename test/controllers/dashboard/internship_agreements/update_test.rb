# frozen_string_literal: true

require 'test_helper'

module Dashboard::InternshipAgreements
  class UpdateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    # As Visitor
    test 'PATCH #update as visitor redirects to new_user_session_path' do
      internship_agreement = create(:troisieme_generale_internship_agreement, employer_accept_terms: true)
      patch dashboard_internship_agreement_path(internship_agreement.id),
            params: { internship_agreement: {school_representative_full_name: 'poupinet'} }
      assert_redirected_to new_user_session_path
    end

    # As Main Teacher
    test 'PATCH #update as main teacher not owning internship_offer redirects to user_session_path' do
      school                 = create(:school, :with_school_manager)
      class_room             = create(:class_room, school: school)
      other_class_room       = create(:class_room, school: school)
      student                = create(:student, school: school, class_room: class_room)
      main_teacher           = create(:main_teacher, school: school, class_room: other_class_room)
      internship_application = create(:weekly_internship_application, :approved, user_id: student.id)
      internship_agreement   = create(:troisieme_generale_internship_agreement, employer_accept_terms: true, internship_application: internship_application)
      sign_in main_teacher
      patch dashboard_internship_agreement_path(internship_agreement.id),
            params: {internship_agreement: {student_class_room: 'a'}}
      assert_redirected_to root_path
    end



    # As Employer
    test 'PATCH #update as employer not owning internship_offer redirects to root path' do
      internship_offer = create(:weekly_internship_offer)
      internship_agreement = create(:troisieme_generale_internship_agreement, employer_accept_terms: true)
      sign_in(create(:employer))
      patch dashboard_internship_agreement_path(internship_agreement.id),
            params: { internship_agreement: {school_representative_full_name: 'poupinet'} }
      assert_redirected_to root_path
    end

    test 'PATCH #update as employer owning internship_offer updates internship_agreement' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, school: school, class_room: class_room)
      main_teacher = create(:main_teacher, school: school, class_room: class_room)
      internship_application = create(:weekly_internship_application, :submitted, user_id: student.id)
      internship_agreement = create(:troisieme_generale_internship_agreement, :created_by_system,
                                    internship_application: internship_application)
      new_organisation_representative_full_name = 'John Doe'
      params = {
        'internship_agreement' => {
          employer_accept_terms: true,
          organisation_representative_full_name: new_organisation_representative_full_name,
          event: 'start_by_employer'
        }
      }
      sign_in(internship_application.internship_offer.employer)

      patch dashboard_internship_agreement_path(internship_agreement.id, params)

      assert_redirected_to(dashboard_internship_agreements_path,
                           'redirection should point to updated agreement')
      assert_equal(new_organisation_representative_full_name,
                  internship_agreement.reload.organisation_representative_full_name,
                  'can\'t update internship_agreement organisation representative full name')
    end

    # As School Manager
    test 'PATCH #update as school manager not owning student redirects to user_session_path' do
      internship_offer = create(:weekly_internship_offer)
      internship_agreement = create(:troisieme_generale_internship_agreement, employer_accept_terms: true)
      sign_in(create(:school_manager))
      patch dashboard_internship_agreement_path(internship_agreement.id),
            params: { internship_agreement: {school_representative_full_name: 'poupinet'} }
      assert_redirected_to root_path
    end

    test 'PATCH #update as school manager owning students updates internship_agreement' do
      internship_application = create(:weekly_internship_application, :approved)
      internship_agreement = create(:troisieme_generale_internship_agreement, :created_by_system,
                                    school_manager_accept_terms: true,
                                    internship_application: internship_application)
      school_manager = internship_application.student.school_manager
      new_school_representative_full_name = 'John Doe'
      params = {
        'internship_agreement' => {
          school_representative_full_name: new_school_representative_full_name,
          event: 'start_by_employer'
        }
      }
      sign_in(school_manager)
      patch dashboard_internship_agreement_path(internship_agreement.id, params)

      assert_redirected_to(dashboard_internship_agreements_path,
                           'redirection should point to updated agreement')
      assert_equal(new_school_representative_full_name,
                   internship_agreement.reload.school_representative_full_name,
                   'can\'t update internship_agreement school representative full name')
    end
  end
end
