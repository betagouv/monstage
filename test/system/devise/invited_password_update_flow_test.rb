# frozen_string_literal: true

require 'application_system_test_case'

class InvitedPasswordUpdateFlowTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'inexistant tutor invited by mail, updates her email' do
    tutor = create(:tutor)
    password = 'kikoo_lool'
    assert tutor.encrypted_password.present?
    raw_reset_password_token = tutor.store_reset_password_token
    visit edit_invited_password_path(reset_password_token: raw_reset_password_token)
    assert_equal I18n.t('devise.invited_passwords.edit.choose_my_password'),
                 find('header.header-account h1').text,
                 "Bad page title"
    assert_equal I18n.t('devise.invited_passwords.edit.choose_my_password'),
                 find('input.btn.btn-primary').value,
                 "Bad CTA button label"
    fill_in('Mot de passe', with: password)
    fill_in('Confirmation de mot de passe', with: password)
    click_on('Choisissez votre mot de passe')
    find '#alert-success #alert-text', text: 'Votre compte a bien été créé.'
  end

  test 'inexistant tutor invited by mail, updates her email with an invalid password' do
    tutor = create(:tutor)
    password = '2shor' # too short
    assert tutor.encrypted_password.present?
    raw_reset_password_token = tutor.store_reset_password_token

    visit edit_invited_password_path(reset_password_token: raw_reset_password_token)
    assert_equal I18n.t('devise.invited_passwords.edit.choose_my_password'),
                find('header.header-account h1').text,
                "Bad page title"
    assert_equal I18n.t('devise.invited_passwords.edit.choose_my_password'),
                find('input.btn.btn-primary').value,
                "Bad CTA button label"
    fill_in('Mot de passe', with: password)
    fill_in('Confirmation de mot de passe', with: password)
    click_on('Choisissez votre mot de passe')
    assert_equal 'Choisissez votre mot de passe',
                  find('h1.h2').text,
                  'Bad redirection to  dashboard_internship_offers_path'
  end
end
# http://localhost:3000/users/invited_password/edit?reset_password_token=xm4yisFuj3ts5W7qZUxD