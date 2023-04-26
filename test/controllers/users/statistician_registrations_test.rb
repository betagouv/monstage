# frozen_string_literal: true

require 'test_helper'

class StatisticianRegistrationsTest < ActionDispatch::IntegrationTest
  test 'GET new as Statistician renders expected inputs' do
    get new_user_registration_path(as: 'PrefectureStatistician')

    assert_response :success
    assert_select 'input', value: 'PrefectureStatistician', hidden: 'hidden'
    assert_select 'title', "Inscription | Monstage"

    assert_select 'label', /Prénom/
    assert_select 'label', /Nom/
    assert_select 'label', /Adresse électronique/
    assert_select 'label', /Créer un mot de passe/
    assert_select 'label', /J'accepte les/
  end

  test 'POST #create with missing params fails creation' do
    email = 'bing@bongo.bang'
    create :statistician_email_whitelist, email: email, zipcode: '60'
    assert_difference('Users::PrefectureStatistician.count', 1) do
      post user_registration_path(params: { user: { email: email,
                                                    first_name: 'dep',
                                                    last_name: 'artement',
                                                    password: 'okokok',
                                                    type: 'Users::PrefectureStatistician',
                                                    accept_terms: '1' }})
      assert_response 302
    end
    refute Users::PrefectureStatistician.last.agreement_signatorable
    refute_nil Users::PrefectureStatistician.last.agreement_signatorable
  end

  test 'when agreement_signatorable goes from false to true a job is launched' do
    statistician = create(:statistician)
    refute statistician.agreement_signatorable
    assert_enqueued_with(job: AgreementsAPosterioriJob) do
      statistician.update(agreement_signatorable: true)
    end
  end
end
