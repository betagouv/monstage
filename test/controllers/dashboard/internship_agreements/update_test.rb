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

    test 'GET #edit as Main teacher owning application student application is successful' do
      school = create(:school, :with_school_manager)
      student = create(:student, :troisieme_segpa, school: school)
      main_teacher = create(:main_teacher, school: school, class_room: student.class_room)
      internship_application = create(:weekly_internship_application, :submitted, user_id: student.id)
      internship_agreement = create(:troisieme_generale_internship_agreement, :created_by_system,
                                    internship_application: internship_application)

      new_main_teacher_full_name = 'Odile Dus'
      params = {
        'internship_agreement' => {
          main_teacher_full_name: new_main_teacher_full_name,
          main_teacher_accept_terms: true,
          event: 'start_by_employer'
        }
      }
      sign_in(main_teacher)

      patch dashboard_internship_agreement_path(internship_agreement.id, params)

      assert_redirected_to(dashboard_internship_agreements_path,
                           'redirection should point to updated agreement')
      assert_equal(new_main_teacher_full_name,
                  internship_agreement.reload.main_teacher_full_name,
                  'can\'t update internship_agreement main_teacher_full_name full name')
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

    # As Tutor
    test 'PATCH #update as tutor not tutor in the internship_offer redirects ' \
         'to dashboard_internship_applications path' do
      tutor = create(:tutor)
      school = create(:school, :with_school_manager, :with_agreement_presets)
      student = create(:student, school: school)
      internship_offer = create(:troisieme_segpa_internship_offer)
      internship_application = create(:free_date_internship_application,
                                      :approved,
                                      student: student,
                                      internship_offer: internship_offer)
      internship_agreement = create(:troisieme_segpa_internship_agreement,
                                    tutor_accept_terms: true,
                                    internship_application: internship_application)
      sign_in(tutor)
      patch dashboard_internship_agreement_path(internship_agreement.id),
            params: { internship_agreement: {tutor_full_name: 'Monsieur Ragnagna'} }
      assert_redirected_to root_path
    end

    test 'PATCH #update as internship_agreement\'s tutor' do
      employer = create(:employer)
      tutor = create(:tutor)
      school = create(:school, :with_school_manager, :with_agreement_presets)
      class_room = create(:class_room, :troisieme_segpa, school: school)
      student = create(:student, school: school, class_room: class_room)
      internship_offer = create(:troisieme_segpa_internship_offer, employer: employer, tutor: tutor)
      internship_application = create(:free_date_internship_application,
                                      :approved,
                                      student: student,
                                      internship_offer: internship_offer)
      internship_agreement = create(:troisieme_segpa_internship_agreement,
                                    tutor_accept_terms: true,
                                    internship_application: internship_application)
      sign_in(tutor)
      new_tutor_full_name = 'M. Lune'
      patch dashboard_internship_agreement_path(internship_agreement.id),
            params: {internship_agreement: {tutor_full_name: new_tutor_full_name, tutor_accept_terms: true, event: 'start_by_employer'}}

      assert_redirected_to(dashboard_internship_agreements_path,
                           'redirection should point to updated agreement')
      assert_equal(new_tutor_full_name,
                  internship_agreement.reload.tutor_full_name,
                  'can\'t update internship_agreement tutor full name')
    end

    test 'PATCH #update as internship_agreement\'s tutor fails when accept_terms are not validated' do
      employer = create(:employer)
      tutor = create(:tutor)
      school = create(:school, :with_school_manager, :with_agreement_presets)
      class_room = create(:class_room, :troisieme_segpa, school: school)
      student = create(:student, school: school, class_room: class_room)
      internship_offer = create(:troisieme_segpa_internship_offer, employer: employer, tutor: tutor)
      internship_application = create(:free_date_internship_application,
                                      :approved,
                                      student: student,
                                      internship_offer: internship_offer)
      internship_agreement = create(:troisieme_segpa_internship_agreement,
                                    tutor_accept_terms: true,
                                    internship_application: internship_application)
      sign_in(tutor)
      new_tutor_full_name = 'M. Lune'
      # there comes the error
      patch dashboard_internship_agreement_path(internship_agreement.id),
            params: {internship_agreement: {tutor_full_name: new_tutor_full_name, tutor_accept_terms: false}}


      internship_agreement = internship_agreement.reload

      refute_equal(new_tutor_full_name,
                   internship_agreement.tutor_full_name,
                   'internship_agreement update should not have validated tutor full name, because tutor_accept_terms was set to false')
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
      internship_agreement = create(:troisieme_generale_internship_agreement,
                                    :created_by_system,
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
