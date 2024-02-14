require 'test_helper'

module Dashboard::Users
  class ResetPhoneNumberControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include TeamAndAreasHelper

    test 'employer resets his phone_number' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
      internship_agreement = create(:internship_agreement, internship_application: internship_application)
      employer.update(phone: '+330602030405')
      sign_in(employer)

      post reset_phone_number_dashboard_user_path( id: employer.id),
           params: {}

      assert_redirected_to dashboard_internship_agreements_path(opened_modal: true)
      follow_redirect!
      assert_select '#alert-text', text: "Votre numéro de téléphone a été supprimé"
      assert employer.reload.phone.blank?
    end

    test 'school_manager resets his phone_number' do
      internship_agreement = create(:internship_agreement, :validated)
      school_manager = internship_agreement.school_manager
      school_manager.update(phone: '+330602030405')
      sign_in(school_manager)

      post reset_phone_number_dashboard_user_path(id: school_manager.id),
           params: {}
      assert_redirected_to dashboard_internship_agreements_path(opened_modal: true)
      follow_redirect!
      assert_select '#alert-text', text: "Votre numéro de téléphone a été supprimé"
      assert school_manager.reload.phone.blank?
    end

    test 'employer is redirected to dashboard_internship_agreements_path when resetting his phone number fails' do
      employer, internship_offer = create_employer_and_offer
      internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
      internship_agreement = create(:internship_agreement, internship_application: internship_application)
      employer.update(phone: '+330602030405')
      klass = Users::Employer
      sign_in(employer)

      klass.stub_any_instance(:nullify_phone_number!, false) do
        post reset_phone_number_dashboard_user_path( id: employer.id), params: {}
      end
      assert_redirected_to dashboard_internship_agreements_path
      follow_redirect!
      assert_select '#alert-warning', content: "Une erreur est survenue et " \
                                         "votre demande n'a pas été traitée"
      assert_equal '+330602030405', employer.reload.phone
    end

    test 'school_manager is redirected to dashboard_internship_agreements_path when resetting his phone number fails' do
      internship_agreement = create(:internship_agreement)
      school_manager = internship_agreement.school_manager
      school_manager.update(phone: '+330602030405')
      klass = Users::SchoolManagement
      sign_in(school_manager)

      klass.stub_any_instance(:nullify_phone_number!, false) do
        post reset_phone_number_dashboard_user_path( id: school_manager.id), params: {}
      end
      assert_redirected_to dashboard_internship_agreements_path
      follow_redirect!
      assert_select '#alert-text', text: "Une erreur est survenue et " \
                                         "votre demande n'a pas été traitée"
      assert_equal '+330602030405', school_manager.reload.phone
    end
  end
end
