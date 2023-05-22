# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Students
    class InternshipApplicationsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      test 'GET internship_applications#index not connected responds with redireciton' do
        student = create(:student)
        get dashboard_students_internship_applications_path(student)
        assert_response :redirect
      end

      test 'GET internship_applications#index as another student responds with redireciton' do
        student_1 = create(:student)
        sign_in(student_1)
        get dashboard_students_internship_applications_path(create(:student))
        assert_response :redirect
      end

      test 'GET internship_applications#index as student.school.school_manager responds with 200' do
        school = create(:school)
        class_room = create(:class_room, school: school)
        student = create(:student, school: school, class_room: class_room)
        school_manager = create(:school_manager, school: school)
        sign_in(school_manager)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
        assert_select 'title', 'Mes candidatures | Monstage'
        assert_select 'h1.h2.mb-3', text: student.name
        assert_select 'a[href=?]', dashboard_school_class_room_students_path(school, class_room)
        assert_select 'h2.h4', text: 'Aucun stage'
      end

      test 'GET internship_applications#index as student.school.school_manager works and show convention button' do
        school = create(:school)
        class_room = create(:class_room, school: school)
        student = create(:student, school: school, class_room: class_room)
        school_manager = create(:school_manager, school: school)
        internship_application = create(:weekly_internship_application, :approved, student: student)
        sign_in(school_manager)
        get dashboard_students_internship_applications_path(student_id: student.id)
        assert_response :success
        assert_select 'a[href=?]', dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application, transition: :signed!)
      end

      test 'GET internship_applications#index as SchoolManagement works and show convention button' do
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        student = create(:student, school: school, class_room: class_room)
        main_teacher = create(:main_teacher, school: school, class_room: class_room)
        internship_application = create(:weekly_internship_application, :approved, student: student)
        sign_in(main_teacher)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
        assert_select 'a[href=?]', dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application, transition: :signed!)
      end

      test 'GET internship_applications#index render navbar, timeline' do
        student = create(:student)
        sign_in(student)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
        assert_template 'dashboard/students/internship_applications/index'
        assert_select 'h1.h2', text: 'Mes candidatures'
        assert_select 'h2.h4', text: 'Aucun stage'
        assert_select 'a.fr-btn[href=?]', student.presenter.default_internship_offers_path
      end

      test 'GET internship_applications#index render internship_applications' do
        student = create(:student)
        states = %i[drafted
                    submitted
                    examined
                    approved
                    expired
                    validated_by_employer
                    rejected
                    canceled_by_employer
                    canceled_by_student]
        internship_applications = states.each_with_object({}) do |state, accu|
          accu[state] = create(:weekly_internship_application, state, student: student)
        end

        sign_in(student)
        get dashboard_students_internship_applications_path(student)
        assert_response :success
        assert_select '.fr-badge.fr-badge--purple-glycine.fr-badge--no-icon', text: 'annulée par l\'élève', count: 1
        assert_select '.fr-badge.fr-badge--error.fr-badge--no-icon', text: 'expirée', count: 1
        assert_select '.fr-badge.fr-badge--success.fr-badge--no-icon', text: "acceptée par l'entreprise", count: 1
        assert_select '.fr-badge.fr-badge--success.fr-badge--no-icon', text: "confirmée", count: 1
        assert_select '.fr-badge.fr-badge--error.fr-badge--no-icon', text: "refusée par l'entreprise", count: 2
        assert_select '.fr-badge.fr-badge--info.fr-badge--no-icon', text: "sans réponse", count: 1
        assert_select '.fr-badge.fr-badge--info.fr-badge--no-icon', text: "à l'étude", count: 1
        assert_select '.fr-badge.fr-badge--no-icon', text: "brouillon", count: 1
      end

      test 'GET internship_applications#show not connected responds with redirection' do
        student = create(:student)
        internship_application = create(:weekly_internship_application, student: student)
        get dashboard_students_internship_application_path(student,
                                                           internship_application)
        assert_response :redirect
      end

      test 'GET internship_applications#show render navbar' do
        student = create(:student)
        sign_in(student)
        internship_application = create(:weekly_internship_application, {
                                          student: student,
                                          aasm_state: :approved,
                                          convention_signed_at: 1.days.ago,
                                          approved_at: 1.days.ago,
                                          validated_by_employer_at: 1.days.ago,
                                          submitted_at: 2.days.ago
                                        })

        get dashboard_students_internship_application_path(student_id: student.id,
                                                           id: internship_application.id)
        assert_response :success

        assert_template 'dashboard/students/internship_applications/show'
        assert_select ".fr-badge.fr-badge--no-icon.fr-badge--success", text:"confirmée"
      end

      test 'GET internship_applications#show with drafted can be submitted' do
        student = create(:student)
        sign_in(student)
        internship_application = create(:weekly_internship_application, student: student)

        get dashboard_students_internship_application_path(student_id: student.id,
                                                           id: internship_application.id)
        assert_response :success
        assert_select ".fr-badge.fr-badge--no-icon", text:"brouillon"
        assert_select "input.fr-btn[type='submit'][value='Envoyer la demande']"
      end

      test "#resend_application" do
        student = create(:student)
        sign_in(student)
        internship_application = create(
          :weekly_internship_application,
          :submitted,
          student: student
        )
        assert_changes -> { internship_application.reload.dunning_letter_count } do
          post resend_application_dashboard_students_internship_application_path(
            student_id: internship_application.student.id,
            id: internship_application.id
            ), params: {}
        end
        assert_equal 1, internship_application.reload.dunning_letter_count
        assert_no_changes -> { internship_application.reload.dunning_letter_count } do
          post resend_application_dashboard_students_internship_application_path(
            student_id: internship_application.student.id,
            id: internship_application.id
            ), params: {}
        end
        assert_redirected_to dashboard_students_internship_applications_path(student)
      end

      test '#direct_to_internship_application' do
        student = create(:student)
        sgid = ""
        internship_application = create(:weekly_internship_application, student: student)
        travel_to Time.now - 3.month do
          sgid = student.to_sgid(expires_in: StudentMailer::MAGIC_LINK_EXPIRATION_DELAY.days).to_s
          get direct_to_internship_application_dashboard_students_internship_application_path(
            sgid: sgid,
            student_id: student.id,
            id: internship_application.id)
          assert_redirected_to dashboard_students_internship_application_path(
            student_id: student.id,
            id: internship_application.id )
          assert_equal student.id, session.dig('warden.user.user.key', 0, 0)
          assert_equal 1, internship_application.reload.magic_link_tracker
          sign_out(student)
        end
        travel_to Time.now do
          get direct_to_internship_application_dashboard_students_internship_application_path(
            sgid: sgid,
            student_id: student.id,
            id: internship_application.id)
          assert_redirected_to dashboard_students_internship_application_path(
            student_id: student.id,
            id: internship_application.id )
          assert_nil session.dig('warden.user.user.key', 0, 0)
          assert_equal 2, internship_application.reload.magic_link_tracker
        end
      end
    end
  end
end
