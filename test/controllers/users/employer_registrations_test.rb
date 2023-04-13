# frozen_string_literal: true

require 'test_helper'

class EmployerRegistrationsTest < ActionDispatch::IntegrationTest
  def assert_employer_form_rendered
    assert_select 'title', "Inscription | Monstage"
    assert_select 'input', value: 'Employer', hidden: 'hidden'
    assert_select 'label', /Adresse électronique/
    assert_select 'label', /Créer un mot de passe/
    assert_select 'label', /J'accepte les/
  end

  test 'GET new as a Employer' do
    get new_user_registration_path(as: 'Employer')

    assert_response :success
    assert_employer_form_rendered
  end

  test 'POST Create Employer' do
    assert_difference('Users::Employer.count') do
      post user_registration_path(params: { user: { email: 'madame@accor.fr',
                                                    password: 'okokok',
                                                    employer_role: 'chef de projet',
                                                    first_name: 'Madame',
                                                    last_name: 'Accor',
                                                    type: 'Users::Employer',
                                                    phone_prefix: '+33',
                                                    phone_suffix: '0612345678',
                                                    accept_terms: '1' } })
    end
    assert_redirected_to users_registrations_standby_path(id: Users::Employer.last.id)
  end

  test "post should not subscribe when confirmation is sent" do
    assert_no_difference('Users::Employer.count') do
      post user_registration_path(params: { user: { email: 'madame@accor.fr',
                                                    confirmation_email: 'madame@accor.fr',
                                                    password: 'okokok',
                                                    employer_role: 'chef de projet',
                                                    first_name: 'Madame',
                                                    last_name: 'Accor',
                                                    type: 'Users::Employer',
                                                    phone_prefix: '+33',
                                                    phone_suffix: '0612345678',
                                                    accept_terms: '1' } })
    end
    assert_redirected_to root_path
    notice = "Votre inscription a bien été prise en compte. " \
             "Vous recevrez un email de confirmation dans " \
             "les prochaines minutes."
    assert_equal notice, flash[:notice]
  end

end
