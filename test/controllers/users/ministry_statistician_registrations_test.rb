# frozen_string_literal: true

require 'test_helper'

class MinistryStatiticianRegistrationsTest < ActionDispatch::IntegrationTest
  test 'GET new as MinistryStatistician renders expected inputs' do
    get new_user_registration_path(as: 'MinistryStatistician')

    assert_response :success
    assert_select 'input', value: 'MinistryStatistician', hidden: 'hidden'
    assert_select 'title', "Inscription | Monstage"

    assert_select 'label', /Prénom/
    assert_select 'label', /Nom/
    assert_select 'label', /Adresse électronique/
    assert_select 'label', /Créer un mot de passe/
    assert_select 'label', /Ressaisir le mot de passe/
    assert_select 'label', /J'accepte les/
  end

  test 'POST #create with right params do not fail creation' do
    email = 'bing@bongo.bang'
    whitelist = create :ministry_statistician_email_whitelist, email: email
    assert_difference('Users::MinistryStatistician.count', 1) do
      post user_registration_path(params: { user: { email: email,
                                                    first_name: 'ref',
                                                    last_name: 'central',
                                                    password: 'okokok',
                                                    password_confirmation: 'okokok',
                                                    type: 'Users::MinistryStatistician',
                                                    accept_terms: '1' } })
      assert_response 302
    end
    last_ministry_statistician = Users::MinistryStatistician.last
    assert_equal email, last_ministry_statistician.email
    assert_equal last_ministry_statistician.ministries, whitelist.groups
  end
end
