require 'test_helper'

class OperatorRegistrationsTest < ActionDispatch::IntegrationTest
  def assert_form_rendered
    assert_select 'input', { value: 'Operator', hidden: 'hidden' }
    assert_select 'label', /Prénom/
    assert_select 'label', /Nom/
    assert_select 'label', /Adresse électronique/
    assert_select 'label', /Choisir un mot de passe/
    assert_select 'label', /Confirmer le mot de passe/
    assert_select 'label', /Opérateur/
  end

  test 'GET new as a Operator renders expected inputs' do
    get new_user_registration_path(as: 'Operator')

    assert_response :success
    assert_form_rendered
  end

  test 'POST #create with missing params fails creation' do
    assert_difference("Users::Operator.count", 0) do
      post user_registration_path(params: { user: { email: 'madame@accor.fr',
                                                    password: 'okokok',
                                                    password_confirmation: 'okokok',
                                                    type: 'Users::Operator',
                                                    first_name: "Martin",
                                                    last_name: "Fourcade" }})
      assert_response 200
      assert_form_rendered
    end
  end

  test 'POST #create with all params create Operator' do
    operator = create(:operator)
    assert_difference("Users::Operator.count", 1) do
      post user_registration_path(params: { user: { email: 'madame@accor.fr',
                                                    password: 'okokok',
                                                    password_confirmation: 'okokok',
                                                    type: 'Users::Operator',
                                                    first_name: "Martin",
                                                    last_name: "Fourcade",
                                                    operator_id:  operator.id }})
      assert_redirected_to root_path
    end
  end
end
