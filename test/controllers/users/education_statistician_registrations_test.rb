# frozen_string_literal: true

require 'test_helper'

class EducationStatisticianRegistrationsTest < ActionDispatch::IntegrationTest
  test 'GET new as EducationStatistician renders expected inputs' do
    get new_user_registration_path(as: 'EducationStatistician')

    assert_response :success
    assert_select 'input', value: 'EducationStatistician', hidden: 'hidden'
    assert_select 'title', "Inscription | Monstage"

    assert_select 'label', /Prénom/
    assert_select 'label', /Nom/
    assert_select 'label', /Adresse électronique/
    assert_select 'label', /Créer un mot de passe/
    assert_select 'label', /J'accepte les/
  end

  test 'POST #create with missing params fails creation' do
    email = 'jean@educ.fr'
    assert_difference('Users::EducationStatistician.count', 0) do
      post user_registration_path(params: { user: { email: email,
                                                    first_name: 'Jean',
                                                    last_name: 'Ref',
                                                    password: 'okokok',
                                                    type: 'Users::EducationStatistician',
                                                    accept_terms: '1' } })
    end
  end

  test 'when agreement_signatorable goes from false to true a job is launched' do
    education_statistician = create(:education_statistician)
    refute education_statistician.agreement_signatorable
    assert_enqueued_with(job: AgreementsAPosterioriJob) do
      education_statistician.update(agreement_signatorable: true)
    end
  end
end
