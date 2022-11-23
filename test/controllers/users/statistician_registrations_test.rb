# frozen_string_literal: true

require 'test_helper'

class StatisticianRegistrationsTest < ActionDispatch::IntegrationTest
  test 'GET new as Statistician renders expected inputs' do
    get new_user_registration_path(as: 'Statistician')

    assert_response :success
    assert_select 'input', value: 'Statistician', hidden: 'hidden'
    assert_select 'title', "Inscription | Monstage"

    assert_select 'label', /Prénom/
    assert_select 'label', /Nom/
    assert_select 'label', /Adresse électronique/
    assert_select 'label', /Créer un mot de passe/
    assert_select 'label', /Ressaisir le mot de passe/
    assert_select 'label', /J'accepte les/
  end

  test 'POST #create with missing params fails creation' do
    email = 'bing@bongo.bang'
    create :statistician_email_whitelist, email: email, zipcode: '60'
    assert_difference('Users::Statistician.count', 1) do
      post user_registration_path(params: { user: { email: email,
                                                    first_name: 'dep',
                                                    last_name: 'artement',
                                                    password: 'okokok',
                                                    password_confirmation: 'okokok',
                                                    type: 'Users::Statistician',
                                                    accept_terms: '1' } })
      assert_response 302
    end
    refute Users::Statistician.last.agreement_signatorable
    refute_nil Users::Statistician.last.agreement_signatorable
  end
end
