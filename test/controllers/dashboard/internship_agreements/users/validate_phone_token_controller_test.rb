require 'test_helper'

module Dashboard::InternshipAgreements::Users
  class ValidatePhoneTokenControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'employer signing fails when using wrong_code' do
      internship_agreement = create(:troisieme_generale_internship_agreement)
      employer = internship_agreement.employer
      employer.update(phone: '+330623456789')
      employer.create_signature_phone_token
      sign_in(employer)

      params = {
        user: {
          internship_agreement_id: internship_agreement.id,
          :'digit-code-target-0' => '1',
          :'digit-code-target-1' => '1',
          :'digit-code-target-2' => '1',
          :'digit-code-target-3' => '1',
          :'digit-code-target-4' => '1',
          :'digit-code-target-5' => '1',
        }
      }
      post signature_code_validate_dashboard_internship_agreement_user_path(
              internship_agreement_id: internship_agreement.id,
              id: employer.id),
             params: params

      assert_redirected_to dashboard_internship_agreements_path
      follow_redirect!
      assert_response :success
      assert_select '#alert-text', text: "Erreur de code, veuillez recommencer"
    end

    test 'employer signing fails when using too old a code params ' do
      internship_agreement = create(:troisieme_generale_internship_agreement)
      employer = internship_agreement.employer
      employer.update(phone: '+330623456789')
      employer.create_signature_phone_token
      sign_in(employer)

      Users::Employer.stub_any_instance(:signature_phone_token_still_ok?, false) do
        Users::Employer.stub_any_instance(:signature_phone_token, '123456') do
          params = {
            user: {
              internship_agreement_id: internship_agreement.id,
              :'digit-code-target-0' => '1',
              :'digit-code-target-1' => '2',
              :'digit-code-target-2' => '3',
              :'digit-code-target-3' => '4',
              :'digit-code-target-4' => '5',
              :'digit-code-target-5' => '6',
            }
          }
          assert_no_difference('Signature.count') do
            post signature_code_validate_dashboard_internship_agreement_user_path(
                  internship_agreement_id: internship_agreement.id,
                  id: employer.id),
                 params: params
          end
          assert_redirected_to dashboard_internship_agreements_path
          follow_redirect!
          assert_response :success
          assert_select '#alert-text',
                        text: "Code périmé, veuillez en réclamer un autre"

        end
      end
    end

    test 'employer creates succeeds with every params ok' do
      internship_agreement = create(:troisieme_generale_internship_agreement, aasm_state: :validated)
      employer = internship_agreement.employer
      employer.update(phone: '+330612345678')
      employer.create_signature_phone_token
      sign_in(employer)
      date = DateTime.new(2020, 1, 1,12,0,0)
      travel_to date do
        Users::Employer.stub_any_instance(:signature_phone_token, '123456') do
          Users::Employer.stub_any_instance(:signature_phone_token_validity, Users::Employer::SIGNATURE_PHONE_TOKEN_VALIDITY.minute.from_now) do
            params = {
              user: {
                internship_agreement_id: internship_agreement.id,
                :'digit-code-target-0' => '1',
                :'digit-code-target-1' => '2',
                :'digit-code-target-2' => '3',
                :'digit-code-target-3' => '4',
                :'digit-code-target-4' => '5',
                :'digit-code-target-5' => '6',
              }
            }
            post signature_code_validate_dashboard_internship_agreement_user_path(
                    internship_agreement_id: internship_agreement.id,
                    id: employer.id),
                  params: params
            assert_redirected_to dashboard_internship_agreements_path
            follow_redirect!
            assert_response :success
            assert_select '#alert-text', text: "Votre code est valide"
            # signature = Signature.first
            # assert_equal signature.internship_agreement.id, internship_agreement.id
            # assert_equal signature.employer.id, employer.id
            # assert_equal signature.signature_phone_number, employer.phone
            # assert_equal 'employer', signature.signatory_role
            # assert_equal date, signature.signature_date
          end
        end
      end
    end

    test 'school_manager signing fails when using wrong_code' do
      internship_agreement = create(:troisieme_generale_internship_agreement)
      school_manager = internship_agreement.school_manager
      school_manager.create_signature_phone_token
      sign_in(school_manager)

      params = {
        user: {
          internship_agreement_id: internship_agreement.id,
          :'digit-code-target-0' => '1',
          :'digit-code-target-1' => '1',
          :'digit-code-target-2' => '1',
          :'digit-code-target-3' => '1',
          :'digit-code-target-4' => '1',
          :'digit-code-target-5' => '1',
        }
      }
      assert_no_difference('Signature.count') do
        post signature_code_validate_dashboard_internship_agreement_user_path(
              internship_agreement_id: internship_agreement.id,
              id: school_manager.id),
             params: params
      end

      assert_redirected_to dashboard_internship_agreements_path
      follow_redirect!
      assert_response :success
      assert_select '#alert-text', text: "Erreur de code, veuillez recommencer"
    end

    test 'school_manager signing fails when using too old a code params ' do
      internship_agreement = create(:troisieme_generale_internship_agreement)
      school_manager = internship_agreement.school_manager
      school_manager.update(phone: '+330612345678')
      school_manager.create_signature_phone_token
      sign_in(school_manager)

      Users::SchoolManagement.stub_any_instance(:signature_phone_token_still_ok?, false) do
        Users::SchoolManagement.stub_any_instance(:signature_phone_token, '123456') do
          params = {
            user: {
              internship_agreement_id: internship_agreement.id,
              :'digit-code-target-0' => '1',
              :'digit-code-target-1' => '2',
              :'digit-code-target-2' => '3',
              :'digit-code-target-3' => '4',
              :'digit-code-target-4' => '5',
              :'digit-code-target-5' => '6',
            }
          }
          post signature_code_validate_dashboard_internship_agreement_user_path(
                internship_agreement_id: internship_agreement.id,
                id: school_manager.id),
                params: params
          assert_redirected_to dashboard_internship_agreements_path
          follow_redirect!
          assert_response :success
          assert_select '#alert-text',
                        text: "Code périmé, veuillez en réclamer un autre"

        end
      end
    end

    test 'school_manager creates succeeds with every params ok' do
      internship_agreement = create(:troisieme_generale_internship_agreement, aasm_state: :validated)
      school_manager = internship_agreement.school_manager
      school_manager.update(phone: '+330612345678')
      sign_in(school_manager)
      date = DateTime.new(2020, 1, 1,12,0,0)
      travel_to date do
        Users::SchoolManagement.stub_any_instance(:signature_phone_token, '123456') do
          Users::SchoolManagement.stub_any_instance(:signature_phone_token_validity, Users::Employer::SIGNATURE_PHONE_TOKEN_VALIDITY.minute.from_now) do
            params = {
              user: {
                internship_agreement_id: internship_agreement.id,
                phone: school_manager.reload.phone,
                :'digit-code-target-0' => '1',
                :'digit-code-target-1' => '2',
                :'digit-code-target-2' => '3',
                :'digit-code-target-3' => '4',
                :'digit-code-target-4' => '5',
                :'digit-code-target-5' => '6'
              }
            }
            post signature_code_validate_dashboard_internship_agreement_user_path(
                    internship_agreement_id: internship_agreement.id,
                    id: school_manager.id),
                  params: params
            # assert_redirected_to dashboard_internship_agreements_path
            # follow_redirect!
            # assert_response :success
            assert_equal date, school_manager.signature_phone_token_checked_at
            target_date = Time.zone.now + Users::SchoolManagement::SIGNATURE_PHONE_TOKEN_VALIDITY.minutes
            assert_equal target_date, school_manager.signature_phone_token_validity
            # assert_select '#alert-text', text: "Votre signature a été enregistrée"
            # signature = Signature.first
            # assert_equal signature.internship_agreement.id, internship_agreement.id
            # assert_equal signature.school_manager.id, school_manager.id
            # assert_equal signature.signature_phone_number, school_manager.phone
            # assert_equal 'school_manager', signature.signatory_role
            # assert_equal date, signature.signature_date
          end
        end
      end
    end
  end
end
