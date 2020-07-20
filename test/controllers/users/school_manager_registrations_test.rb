# frozen_string_literal: true

require 'test_helper'

class SchoolManagerRegistrationsTest < ActionDispatch::IntegrationTest
  test 'GET new as a SchoolManager' do
    get new_user_registration_path(as: 'SchoolManagement')

    assert_response :success
    assert_select 'input', value: 'SchoolManagement', hidden: 'hidden'
    assert_select 'label', /J'accepte les/
  end

  test 'POST create School Manager responds with success' do
    school = create(:school)
    assert_difference('Users::SchoolManagement.school_manager.count', 1) do
      post user_registration_path(params: { user: { email: 'chefetb@ac-edu.fr',
                                                    password: 'okokok',
                                                    password_confirmation: 'okokok',
                                                    school_id: school.id,
                                                    first_name: 'Chef',
                                                    last_name: 'Etablissement',
                                                    type: 'Users::SchoolManagement',
                                                    accept_terms: '1',
                                                    role: :school_manager } })
      assert_redirected_to users_registrations_standby_path(email: 'chefetb@ac-edu.fr')
    end
  end
end
