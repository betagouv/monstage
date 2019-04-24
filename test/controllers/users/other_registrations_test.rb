require 'test_helper'

class OtherRegistrationsTest < ActionDispatch::IntegrationTest
  def assert_form_rendered
    assert_select 'input', { value: 'Other', hidden: 'hidden' }
    assert_select 'label', /Ville de mon collège/
    assert_select 'label', /Collège/
    assert_select 'label', /Adresse électronique/
    assert_select 'label', /Choisir un mot de passe/
    assert_select 'label', /Confirmer le mot de passe/
  end

  test 'GET new as a Other renders expected inputs' do
    get new_user_registration_path(as: 'Other')

    assert_response :success
    assert_form_rendered
  end

  test 'POST #create with missing params fails creation' do
    assert_difference("Users::Other.count", 0) do
      post user_registration_path(params: { user: { email: 'madame@accor.fr',
                                                    password: 'okokok',
                                                    password_confirmation: 'okokok',
                                                    type: 'Users::Other',
                                                    first_name: "Martin",
                                                    last_name: "Fourcade" }})
      assert_response 200
      assert_form_rendered
    end
  end

  test 'POST #create with all params create Other' do
    school = create(:school)
    school_manager = create(:school_manager, school: school)
    assert_difference("Users::Other.count", 1) do
      post user_registration_path(params: { user: { email: 'madame@accor.fr',
                                                    password: 'okokok',
                                                    password_confirmation: 'okokok',
                                                    type: 'Users::Other',
                                                    first_name: "Martin",
                                                    last_name: "Fourcade",
                                                    school_id:  school.id}})
      assert_redirected_to root_path
    end
  end
end

