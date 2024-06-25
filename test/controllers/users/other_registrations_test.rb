# frozen_string_literal: true

require 'test_helper'

class OtherRegistrationsTest < ActionDispatch::IntegrationTest
  def assert_other_form_rendered
    assert_select 'input', value: 'SchoolManagement', hidden: 'hidden'
    assert_select 'label', /Adresse électronique/
    assert_select 'label', /Créer un mot de passe/
    assert_select 'label', /J'accepte les/
  end

  test 'GET new as a Other renders expected inputs' do
    get new_user_registration_path(as: 'SchoolManagement')

    assert_response :success
    assert_other_form_rendered
  end

  test 'POST #create with missing params fails creation' do
    assert_difference('Users::SchoolManagement.other.count', 0) do
      post user_registration_path(params: { user: { email: 'cpe@edu.fr',
                                                    password: 'okokoK123456@!',
                                                    type: 'Users::SchoolManagement',
                                                    first_name: 'Martin',
                                                    last_name: 'Fourcade',
                                                    accept_terms: '1' } })
      assert_response 200
      assert_other_form_rendered
    end
  end

  test 'POST #create with all params create Other' do
    school = create(:school)
    create(:school_manager, school: school)
    assert_difference('Users::SchoolManagement.other.count', 1) do
      post user_registration_path(params: { user: { email: "cpe@#{school.email_domain_name}",
                                                    password: 'okokoK123456@!',
                                                    type: 'Users::SchoolManagement',
                                                    first_name: 'Martin',
                                                    last_name: 'Fourcade',
                                                    school_id: school.id,
                                                    accept_terms: '1',
                                                    role: :other } })
      assert_redirected_to users_registrations_standby_path(id: User.last.id)
    end
  end
end
