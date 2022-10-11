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
    assert_select 'a[href=?]', '/identities/new?as=Student'
    assert_select 'a[href=?]', '/users/sign_up?as=Employer'
    assert_select 'a[href=?]', '/users/sign_up?as=SchoolManagement'
    assert_select 'a[href=?]', '/users/sign_up?as=Statistician'
    assert_select 'a[href=?]', '/users/sign_up?as=MinistryStatistician'
  end

  test 'GET #registrations_standby as student using path?id=#id with pending account' do
    email = 'fourcade.m@gmail.com'
    student = create(:student, email: email, confirmed_at: nil)
    get users_registrations_standby_path(id: student.id)
    assert_response :success
    assert_select('p.h2', text: '1 . Activez votre compte !')
  end

  test 'GET #registrations_standby as employer using path?id=#id with pending account' do
    email = 'fourcade.m@gmail.com'
    employer = create(:employer, email: email, confirmed_at: nil)
    get users_registrations_standby_path(id: employer.id)
    assert_response :success
    assert_select('p.h2', text: '1 . Activez votre compte !')
  end

  test 'GET #registrations_standby using path?id=#id with confirmed account' do
    email = 'fourcade.m@gmail.com'
    student = create(:student, email: email, confirmed_at: Time.now)
    get users_registrations_standby_path(id: student.id)
    assert_response :success
    assert_select '.alert.alert-success', text: "Votre compte est déjà confirmé (#{email}).Veuillez vous connecter"
  end

  # What use case ??
  test 'GET #registrations_standby using path?id=#id with unknown account' do
    random_id = 132
    get users_registrations_standby_path(id: random_id)
    assert_response :success
    assert_select '.alert.alert-danger', text: "Aucun compte n'est lié à cet identifiant : #{random_id}.Veuillez créer un compte"
  end

  test 'GET #users_registrations_phone_standby as student using path?id=#id with pending account' do
    phone = '+330611223344'
    create(:student, phone: phone, confirmed_at: nil)
    get users_registrations_phone_standby_path(phone: phone)
    assert_response :success
    assert_select('h1.h2', text: 'Encore une petite étape...')
  end

  test 'GET #registrations_standby using path?phone=0611223344 with confirmed phone' do
    phone = '+330611223344'
    student = create(:student, phone: phone, phone_token_validity: nil)
    get users_registrations_phone_standby_path(id: student.id)
    assert_response :success
    assert_select '.alert.alert-success', text: "Votre compte est déjà confirmé (#{phone}).Veuillez vous connecter"
  end

  # What use case ??
  # test 'GET #registrations_standby using path?id=#id with unknown account but whith phone' do
  #   phone = '+330611223344'
  #   get users_registrations_phone_standby_path(phone: phone)
  #   assert_response :success
  #   assert_select '.alert.alert-danger', text: "Aucun compte n'est lié au téléphone: #{phone}.Veuillez créer un compte"
  # end

  test 'POST #phone_validation redirect to sign in with phone preselected' do
    phone = '+330611223344'
    student = create(:student, email: nil, phone: phone, phone_token: '1234')
    post phone_validation_path(phone: phone, phone_token: student.phone_token)
    assert_redirected_to new_user_session_path(phone: phone)
  end
end
