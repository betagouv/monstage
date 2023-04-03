# frozen_string_literal: true

require 'test_helper'

module InternshipOffers::InternshipApplications
  class UpdateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include ActionMailer::TestHelper

    test 'PATCH #update with approve! any no custom message transition sends email' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, school:school, class_room: class_room)
      internship_application = create(
        :weekly_internship_application,
        :submitted,
        user_id: student.id
      )
      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 2 do
        patch(
          dashboard_internship_offer_internship_application_path(
            internship_application.internship_offer,
            internship_application ),
            params: { transition: :approve! })
          assert_redirected_to internship_application.internship_offer.employer.after_sign_in_path
      end
      assert_equal 1,
                  InternshipAgreement.count
      assert_equal internship_application.id,
                  InternshipAgreement.first.internship_application.id
      follow_redirect!
      validation_text = 'Candidature mise à jour avec succès. ' \
                        'Vous pouvez renseigner la convention dès maintenant.'
      assert_select('#alert-text', text: validation_text)
      assert_equal true, InternshipApplication.last.approved?
      assert_equal 1, InternshipAgreement.count
    end

    test 'PATCH #update with approve! when employer is a statistician it does not create internship agreement' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, school:school, class_room: class_room)
      internship_application = create(
        :weekly_internship_application,
        :submitted,
        user_id: student.id
      )
      internship_application.internship_offer.employer.update(type: 'Users::PrefectureStatistician')

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 1 do
        patch(
          dashboard_internship_offer_internship_application_path(
            internship_application.internship_offer,
            internship_application ),
            params: { transition: :approve! })
          assert_redirected_to internship_application.internship_offer.employer.after_sign_in_path
      end
      assert_equal 0, InternshipAgreement.count
    end

    test 'PATCH #update with approve! when employer is a statistician that can sign agreements , it does create internship agreement' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, school:school, class_room: class_room)
      internship_application = create(
        :weekly_internship_application,
        :submitted,
        user_id: student.id
      )
      employer = internship_application.internship_offer.employer
      employer.becomes(Users::PrefectureStatistician)
      employer.update(agreement_signatorable: true)

      sign_in(employer)

      assert_enqueued_emails 2 do
        patch(
          dashboard_internship_offer_internship_application_path(
            internship_application.internship_offer, 
            internship_application),
          params: { transition: :approve! }
        )
        assert_redirected_to employer.after_sign_in_path
      end
      assert_equal 1, InternshipAgreement.count
    end

    test 'PATCH #update with approve! when employer is an operator it does not create internship agreement' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, school:school, class_room: class_room)
      internship_application = create(
        :weekly_internship_application,
        :submitted,
        user_id: student.id
      )
      internship_application.internship_offer.employer.update(type: 'Users::Operator')

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 1 do
        patch(
          dashboard_internship_offer_internship_application_path(
            internship_application.internship_offer,
            internship_application ),
            params: { transition: :approve! })
          assert_redirected_to internship_application.internship_offer.employer.after_sign_in_path
      end
      assert_equal 0, InternshipAgreement.count
    end

    test 'PATCH #update with approve! when school has no school_manager it does not create internship agreement' do
      school = create(:school)
      class_room = create(:class_room, school: school)
      student = create(:student, school:school, class_room: class_room)
      internship_application = create(
        :weekly_internship_application,
        :submitted,
        user_id: student.id
      )
      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 2 do # Student and school_manager receive emails
        patch(
          dashboard_internship_offer_internship_application_path(
            internship_application.internship_offer,
            internship_application ),
            params: { transition: :approve! })
          assert_redirected_to internship_application.internship_offer.employer.after_sign_in_path
      end
      assert_equal 0, InternshipAgreement.count
    end

    test 'PATCH #update with approve! and a custom message transition sends email' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, school:school, class_room: class_room)
      internship_application = create(
        :weekly_internship_application,
        :submitted,
        user_id: student.id
      )
      internship_offer = internship_application.internship_offer

      sign_in(internship_offer.employer)

      assert_enqueued_emails 2 do
        assert_changes -> { InternshipAgreement.all.count },
                     from: 0,
                     to: 1 do
          update_url = dashboard_internship_offer_internship_application_path(
            internship_offer,
            internship_application
          )
          patch(update_url, params: {
                  transition: :approve!,
                  internship_application: { approved_message: 'OK' }
                })
          assert_redirected_to internship_offer.employer.after_sign_in_path
        end
      end
      internship_application.reload

      assert_equal 'OK', internship_application.approved_message.try(:to_plain_text)
      assert InternshipApplication.last.approved?
    end

    test 'PATCH #update with reject! transition sends email' do
      internship_application = create(:weekly_internship_application, :submitted)

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 1 do
        patch(dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
              params: { transition: :reject! })
        assert_redirected_to internship_application.internship_offer.employer.after_sign_in_path
      end

      assert InternshipApplication.last.rejected?
    end

    test 'PATCH #update with reject! and a custom message transition sends email' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, school:school, class_room: class_room)
      internship_application = create(
        :weekly_internship_application,
        :submitted,
        user_id: student.id
      )
      internship_offer = internship_application.internship_offer

      sign_in(internship_offer.employer)

      assert_enqueued_emails 2 do
        update_url = dashboard_internship_offer_internship_application_path(
          internship_offer,
          internship_application
        )
        patch(update_url, params: {
                transition: :approve!,
                internship_application: { rejected_message: 'OK' }
              })
        assert_redirected_to internship_offer.employer.after_sign_in_path
      end
      internship_application.reload

      assert_equal 'OK', internship_application.rejected_message.try(:to_plain_text)
      assert InternshipApplication.last.approved?
    end

    test 'PATCH #update with cancel_by_employer! send email, change aasm_state' do
      internship_application = create(:weekly_internship_application, :approved)

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 1 do
        patch(dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
              params: { transition: :cancel_by_employer!,
                        internship_application: { canceled_by_employer_message: 'OK' } })
        assert_redirected_to internship_application.internship_offer.employer.after_sign_in_path
      end
      internship_application.reload

      assert_equal 'OK', internship_application.canceled_by_employer_message.try(:to_plain_text)
      assert internship_application.canceled_by_employer?
    end

    test 'PATCH #update with cancel_by_student! send email, change aasm_state' do
      student = create(:student)
      internship_application = create(:weekly_internship_application, :submitted, student: student)

      sign_in(internship_application.student)

      assert_enqueued_emails 1 do
        patch(
          dashboard_internship_offer_internship_application_path(
            internship_application.internship_offer, internship_application
          ),
          params: { transition: :cancel_by_student!,
                    internship_application: { canceled_by_student_message: 'OK' } }
        )
        assert_redirected_to dashboard_students_internship_applications_path(student)
      end
      internship_application.reload

      assert_equal 'OK', internship_application.canceled_by_student_message.try(:to_plain_text)
      assert internship_application.canceled_by_student?

      follow_redirect!
      assert_select('#alert-text', text: 'Candidature mise à jour avec succès.')
    end

    test 'PATCH #update with lol! fails gracefully' do
      internship_application = create(:weekly_internship_application, :approved)

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 0 do
        patch(dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
              params: { transition: :lol! })
        assert_redirected_to internship_application.internship_offer.employer.after_sign_in_path
      end
      internship_application.reload

      assert internship_application.approved?
    end

    test 'PATCH #update as employer with signed! does not send email, change aasm_state' do
      internship_application = create(:weekly_internship_application, :approved)

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 0 do
        patch(dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
              params: { transition: :signed! })
        assert_redirected_to internship_application.internship_offer.employer.after_sign_in_path
      end
      internship_application.reload
      assert internship_application.convention_signed?
    end

    test 'PATCH #update as school manager works' do
      school = create(:school, :with_school_manager)
      student = create(:student, school: school)
      internship_application = create(:weekly_internship_application, :approved, student: student)

      sign_in(school.school_manager)

      assert_enqueued_emails 0 do
        patch(dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
              params: { transition: :signed! })
        assert_redirected_to school.school_manager.after_sign_in_path
      end
      internship_application.reload
      assert internship_application.convention_signed?
    end
  end
end
