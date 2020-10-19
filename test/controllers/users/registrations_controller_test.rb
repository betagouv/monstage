# frozen_string_literal: true

require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test 'GET new redirects if no type is chosen' do
    get new_user_registration_path
    assert_redirected_to users_choose_profile_path
  end

  test 'GET #choose_profile' do
    get users_choose_profile_path
    assert_select 'title', "Création de compte | Monstage"
    assert_select 'a[href=?]', '/users/sign_up?as=Student'
    assert_select 'a[href=?]', '/users/sign_up?as=Employer'
    assert_select 'a[href=?]', '/users/sign_up?as=SchoolManagement'
    assert_select 'a[href=?]', '/users/sign_up?as=Statistician'
  end

  test 'GET #registrations_standby as student using path?email=fourcade.m@gmail.com with pending account' do
    email = 'fourcade.m@gmail.com'
    create(:student, email: email, confirmed_at: nil)
    get users_registrations_standby_path(email: email)
    assert_response :success
    assert_select 'span.confirmation-text', text: 'Votre compte a bien été enregistré'
  end

  test 'GET #registrations_standby as employer using path?email=fourcade.m@gmail.com with pending account' do
    email = 'fourcade.m@gmail.com'
    create(:employer, email: email, confirmed_at: nil)
    get users_registrations_standby_path(email: email)
    assert_response :success
    assert_select 'span.confirmation-text', text: 'Votre compte a bien été enregistré'
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

  test 'GET #users_registrations_phone_standby as student using path?phone=+330611223344 with pending account' do
    phone = '+330611223344'
    create(:student, phone: phone, confirmed_at: nil)
    get users_registrations_phone_standby_path(phone: phone)
    assert_response :success
    assert_select 'span.confirmation-text', text: 'Votre compte a bien été enregistré'
  end

  test 'GET #registrations_standby using path?phone=0611223344 with confirmed phone' do
    phone = '+330611223344'
    create(:student, phone: phone, phone_token_validity: nil)
    get users_registrations_phone_standby_path(phone: phone)
    assert_response :success
    assert_select '.alert.alert-success', text: "Votre compte est déjà confirmé (#{phone}).Veuillez vous connecter"
  end

  test 'GET #registrations_standby using path?phone=+330611223344 with unknown account' do
    phone = '+330611223344'
    get users_registrations_phone_standby_path(phone: phone)
    assert_response :success
    assert_select '.alert.alert-danger', text: "Aucun compte n'est lié au téléphone: #{phone}.Veuillez créer un compte"
  end

  test 'POST #phone_validation redirect to sign in with phone preselected' do
    phone = '+330611223344'
    student = create(:student, email: nil, phone: phone, phone_token: '1234')
    post phone_validation_path(phone: phone, phone_token: student.phone_token)
    assert_redirected_to new_user_session_path(phone: phone)
  end
end
