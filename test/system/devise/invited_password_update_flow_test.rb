# frozen_string_literal: true

require 'application_system_test_case'

class InvitedPasswordUpdateFlowTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'inexistant tutor invited by mail, updates her email' do
    tutor = create(:tutor)
    password = 'kikoo_lool'
    assert tutor.encrypted_password.present?
    raw_reset_password_token = tutor.store_reset_password_token
    visit invited_edit_password_path(reset_password_token: raw_reset_password_token)
    assert_equal I18n.t('devise.passwords.invited_edit_password.choose_my_password'),
                 find('header.header-account h1').text,
                 "Bad page title"
    assert_equal I18n.t('devise.passwords.invited_edit_password.choose_my_password'),
                 find('input.btn.btn-primary').value,
                 "Bad CTA button label"
    fill_in('Mot de passe', with: password)
    fill_in('Confirmation de mot de passe', with: password)
    click_on('Choisissez votre mot de passe')
    assert_equal 'Mes offres de stage',
                  find('.container h1.h3').text,
                  'Bad redirection to  dashboard_internship_offers_path'
  end
end
