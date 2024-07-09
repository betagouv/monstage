# frozen_string_literal: true

require 'test_helper'

module InternshipOffers::InternshipApplications
  class UpdateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include ActionMailer::TestHelper

    test 'PATCH #update with approve! any no custom message transition sends email' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, school: school, class_room: class_room)
      internship_offer = create(:weekly_internship_offer, employer: create(:employer))
      internship_application = create(
        :weekly_internship_application,
        :validated_by_employer,
        internship_offer: internship_offer,
        user_id: student.id
      )
      assert school.school_manager.present?
      sign_in(internship_offer.employer)

      #since no main_teacher and mails to school_manager and employer are delivered later(they are queued)
      assert_enqueued_emails 1 do
        patch(
          dashboard_internship_offer_internship_application_path(
            internship_offer,
            internship_application ),
            params: { transition: :approve! })
          assert_redirected_to internship_offer.employer.custom_candidatures_path(tab: :approve!)
      end
      assert_equal 1, InternshipAgreement.count
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
        :validated_by_employer,
        user_id: student.id
      )
      internship_application.internship_offer.employer.update(type: 'Users::PrefectureStatistician')

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 0 do
        params = { transition: :approve! }
        patch(
          dashboard_internship_offer_internship_application_path(
            internship_application.internship_offer,
            internship_application ),
          params: params)
          assert_redirected_to internship_application.internship_offer.employer.custom_candidatures_path(tab: :approve!)
      end
      assert_equal 0, InternshipAgreement.count
    end

    test 'PATCH #update with approve! when employer is a statistician that can sign agreements , it does create internship agreement' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, school:school, class_room: class_room)
      internship_application = create(
        :weekly_internship_application,
        :validated_by_employer,
        user_id: student.id
      )
      employer = internship_application.internship_offer.employer
      employer.becomes(Users::PrefectureStatistician)
      employer.update(agreement_signatorable: true)

      sign_in(employer)

      assert_enqueued_emails 1 do
        patch(
          dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
          params: { transition: :approve! })
        assert_redirected_to employer.custom_candidatures_path(tab: :approve!)
      end
      assert_equal 1, InternshipAgreement.count
    end

    test 'PATCH #update with approve! when employer is an operator it does not create internship agreement' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, school:school, class_room: class_room)
      internship_application = create(
        :weekly_internship_application,
        :validated_by_employer,
        user_id: student.id
      )
      employer = internship_application.internship_offer.employer
      employer.update(type: 'Users::Operator', operator_id: create(:operator).id)
      operator = Users::Operator.find_by(id: employer.id)

      sign_in(operator)

      assert_enqueued_emails 0 do
        patch(
          dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
          params: { transition: :approve! }
        )
        assert_redirected_to operator.custom_candidatures_path(tab: :approve!)
      end
      assert_equal 0, InternshipAgreement.count
    end

    test 'PATCH #update with approve! when school has no school_manager it does not create internship agreement' do
      school = create(:school)
      class_room = create(:class_room, school: school)
      student = create(:student, school:school, class_room: class_room)
      internship_application = create(
        :weekly_internship_application,
        :validated_by_employer,
        user_id: student.id
      )
      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 0 do # Student receives email
        patch(
          dashboard_internship_offer_internship_application_path(
            internship_application.internship_offer,
            internship_application ),
            params: { transition: :approve! })
          assert_redirected_to internship_application.internship_offer.employer.custom_candidatures_path(tab: :approve!)
      end
      assert_equal 0, InternshipAgreement.count
    end

    test 'PATCH #update with approve! and a custom message transition sends email' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, school:school, class_room: class_room)
      internship_application = create(
        :weekly_internship_application,
        :validated_by_employer,
        user_id: student.id
      )
      internship_offer = internship_application.internship_offer

      sign_in(internship_offer.employer)

      assert_enqueued_emails 1 do
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
          assert_redirected_to internship_offer.employer.custom_candidatures_path(tab: :approve!)
        end
      end
      internship_application.reload

      assert_equal 'OK', internship_application.approved_message.try(:to_plain_text)
      assert InternshipApplication.last.approved?
    end

    test 'PATCH #update with employer_validate! sends email and job' do
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

      assert_enqueued_jobs 1, only: CancelValidatedInternshipApplicationJob do
        assert_enqueued_emails 1 do
         
          update_url = dashboard_internship_offer_internship_application_path(
            internship_offer,
            internship_application
          )
          patch(update_url, params: {
                  transition: :employer_validate!,
                  internship_application: { approved_message: 'OK' }
                })
          assert_redirected_to internship_offer.employer.custom_candidatures_path(tab: :employer_validate!)
          
        end
      end
      internship_application.reload
      assert InternshipApplication.last.validated_by_employer?
    end

    test 'PATCH #update with approve! and update all other student internship_application' do
      if ENV['RUN_BRITTLE_TEST']
        school = create(:school, :with_school_manager)
        class_room = create(:class_room, school: school)
        student = create(:student, school:school, class_room: class_room)
        internship_application = create(
          :weekly_internship_application,
          :validated_by_employer,
          user_id: student.id
        )
        internship_application_2 = create(
          :weekly_internship_application,
          :submitted,
          user_id: student.id
        )
        internship_offer = internship_application.internship_offer

        sign_in(internship_offer.employer)

        assert_enqueued_jobs 1, only: SendSmsJob do
          assert_enqueued_emails 1 do
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
              assert_redirected_to internship_offer.employer.custom_candidatures_path(tab: :approve!)
            end
          end
        end
        internship_application.reload
        internship_application_2.reload

        assert_equal 'OK', internship_application.approved_message.try(:to_plain_text)
        assert_equal true, internship_application.approved?
        assert_equal 'canceled_by_student_confirmation', internship_application_2.aasm_state
      end
    end

    test 'PATCH #update with approve! and update all other student internship_application and send emails to others employers' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, school:school, class_room: class_room)
      internship_application = create(
        :weekly_internship_application,
        :validated_by_employer,
        user_id: student.id
      )
      internship_application_2 = create(
        :weekly_internship_application,
        :read_by_employer,
        user_id: student.id
      )
      internship_application_3 = create(
        :weekly_internship_application,
        :read_by_employer,
        user_id: student.id
      )
      internship_application_4 = create(
        :weekly_internship_application,
        :read_by_employer,
        user_id: student.id
      )
      internship_offer = internship_application.internship_offer

      sign_in(internship_offer.employer)

      assert_enqueued_emails 4 do # 3 others applications emails + 1 for new agreement
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
          assert_redirected_to internship_offer.employer.custom_candidatures_path(tab: :approve!)
        end
      end
      internship_application.reload
      internship_application_2.reload
      internship_application_3.reload
      internship_application_4.reload

      assert_equal 'OK', internship_application.approved_message.try(:to_plain_text)
      assert_equal true, internship_application.approved?
      assert_equal 'canceled_by_student_confirmation', internship_application_2.aasm_state
      assert_equal 'canceled_by_student_confirmation', internship_application_3.aasm_state
      assert_equal 'canceled_by_student_confirmation', internship_application_4.aasm_state
    end

    test 'PATCH #update with reject! transition sends email' do
      internship_application = create(:weekly_internship_application, :submitted)

      sign_in(internship_application.internship_offer.employer)

      assert_enqueued_emails 1 do
        patch(dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
              params: { transition: :reject! })
        assert_redirected_to internship_application.internship_offer.employer.custom_candidatures_path(tab: :reject!)
      end

      assert InternshipApplication.last.rejected?
    end

    test 'PATCH #update with reject! and a custom message transition sends email' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, school:school, class_room: class_room)
      internship_application = create(
        :weekly_internship_application,
        :validated_by_employer,
        user_id: student.id
      )
      internship_offer = internship_application.internship_offer

      sign_in(internship_offer.employer)

      assert_enqueued_emails 1 do
        update_url = dashboard_internship_offer_internship_application_path(
          internship_offer,
          internship_application
        )
        patch(update_url, params: {
                transition: :approve!,
                internship_application: { rejected_message: 'OK' }
        })
        assert_redirected_to internship_offer.employer.custom_candidatures_path(tab: :approve!)
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
        assert_redirected_to internship_application.internship_offer.employer.custom_candidatures_path(tab: :cancel_by_employer!)
      end
      internship_application.reload

      assert_equal 'OK', internship_application.canceled_by_employer_message.try(:to_plain_text)
      assert internship_application.canceled_by_employer?
      assert_nil internship_application.internship_agreement
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

    test 'patch #update employer examining a student application' do
      freeze_time do
        t_now = Time.zone.now
        internship_offer = create(:weekly_internship_offer)
        assert internship_offer.valid?
        internship_application = create(:weekly_internship_application, :submitted, internship_offer: internship_offer)
        sign_in(internship_offer.employer)

        patch dashboard_internship_offer_internship_application_path(internship_offer,
                                                          internship_application,
                                                          transition: :examine!)
        assert_response :redirect
        assert_redirected_to internship_offer.employer.custom_candidatures_path(tab: :examine!)
        assert_equal t_now, internship_application.reload.examined_at
      end
    end

    test 'patch #update not sign in employer examining a student application with token' do
      freeze_time do
        t_now = Time.zone.now
        internship_offer = create(:weekly_internship_offer)
        assert internship_offer.valid?
        internship_application = create(:weekly_internship_application, :examined, internship_offer: internship_offer)
        

        patch dashboard_internship_offer_internship_application_path(internship_offer,
                                                          internship_application,
                                                          transition: :approve!,
                                                          token: internship_application.access_token)
        assert_response :redirect
        assert_redirected_to root_path
        internship_application.reload
        assert_equal 'examined', internship_application.aasm_state
      end
    end

    test 'PATCH when application is approved #update with cancel_by_employer! delete agreement' do
      internship_application = create(:weekly_internship_application, :approved)
      assert internship_application.internship_agreement
      sign_in(internship_application.internship_offer.employer)
      
      patch(dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
              params: { transition: :cancel_by_employer!,
                        internship_application: { canceled_by_employer_message: 'OK' } })
        
      internship_application.reload
      assert_equal 'OK', internship_application.canceled_by_employer_message.try(:to_plain_text)
      assert internship_application.canceled_by_employer?
      assert_nil internship_application.internship_agreement
    end

    test 'PATCH when application is approved #update with cancel_by_student! delete agreement' do
      internship_application = create(:weekly_internship_application, :approved)
      assert internship_application.internship_agreement
      sign_in(internship_application.internship_offer.employer)

      patch(dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
              params: { transition: :cancel_by_student!,
                        internship_application: { canceled_by_employer_message: 'OK' } })
        
      internship_application.reload
      assert_equal 'OK', internship_application.canceled_by_employer_message.try(:to_plain_text)
      assert internship_application.canceled_by_student?
      assert_nil internship_application.internship_agreement
    end
  end
end
