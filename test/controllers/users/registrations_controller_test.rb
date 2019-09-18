# frozen_string_literal: true

require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test 'GET new redirects if no type is chosen' do
    get new_user_registration_path
    assert_redirected_to users_choose_profile_path
  end

  test 'GET #choose_profile' do
    get users_choose_profile_path

    assert_select 'a[href=?]', '/users/sign_up?as=Student'
    assert_select 'a[href=?]', '/users/sign_up?as=Employer'
    assert_select 'a[href=?]', '/users/sign_up?as=SchoolManager'
    assert_select 'a[href=?]', '/users/sign_up?as=MainTeacher'
    assert_select 'a[href=?]', '/users/sign_up?as=Other'
    assert_select 'a[href=?]', '/users/sign_up?as=Teacher'
    assert_select 'a[href=?]', '/users/sign_up?as=Statistician'
  end

  test 'GET #registrations_standby as student using path?email=fourcade.m@gmail.com with pending account' do
    email = 'fourcade.m@gmail.com'
    create(:student, email: email, confirmed_at: nil)
    get users_registrations_standby_path(email: email)
    assert_response :success
    assert_select '.alert.alert-warning', text: "Un message d'activation a été envoyé à #{email}.Veuillez suivre les instructions qu'il contient"
    assert_select ".test-student-guidelines", count: 1
  end
  test 'GET #registrations_standby as employer using path?email=fourcade.m@gmail.com with pending account' do
    email = 'fourcade.m@gmail.com'
    create(:employer, email: email, confirmed_at: nil)
    get users_registrations_standby_path(email: email)
    assert_response :success
    assert_select '.alert.alert-warning', text: "Un message d'activation a été envoyé à #{email}.Veuillez suivre les instructions qu'il contient"
    assert_select ".test-student-guidelines", count: 0
  end

  test 'GET #registrations_standby using path?email=fourcade.m@gmail.com with confirmed account' do
    email = 'fourcade.m@gmail.com'
    create(:student, email: email, confirmed_at: Time.now)
    get users_registrations_standby_path(email: email)
    assert_response :success
    assert_select '.alert.alert-success', text: "Votre compte est déjà confirmé (#{email}).Veuillez vous connecter"
  end

  test 'GET #registrations_standby using path?email=fourcade.m@gmail.com with unknown account' do
    email = 'fourcade.m@gmail.com'
    get users_registrations_standby_path(email: email)
    assert_response :success
    assert_select '.alert.alert-danger', text: "Aucun compte n'est lié au mail: #{email}.Veuillez créer un compte"
  end
end
