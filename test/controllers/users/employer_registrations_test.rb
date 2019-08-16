# frozen_string_literal: true

require 'test_helper'

class EmployerRegistrationsTest < ActionDispatch::IntegrationTest
  test 'GET new as a Employer' do
    get new_user_registration_path(as: 'Employer')

    assert_response :success
    assert_select 'input', value: 'Employer', hidden: 'hidden'
    assert_select 'label', /Adresse électronique/
    assert_select 'label', /Choisir un mot de passe/
    assert_select 'label', /Confirmer le mot de passe/
  end

  test 'POST Create Employer' do
    assert_difference('Users::Employer.count') do
      post user_registration_path(params: { user: { email: 'madame@accor.fr',
                                                    password: 'okokok',
                                                    password_confirmation: 'okokok',
                                                    first_name: 'Madame',
                                                    last_name: 'Accor',
                                                    type: 'Users::Employer' } })
      assert_redirected_to users_registrations_standby_path(email: 'madame@accor.fr')
    end
  end
end
