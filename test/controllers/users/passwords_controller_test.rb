# frozen_string_literal: true

require 'test_helper'

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  test 'POST update with invalid token fails gracefully' do
    put user_password_path, params: {
      user: {
        password: '123456',
        password_confirmation: '123456',
        reset_password_token: 'invalid'
      }
    }

    assert_select '#error_explanation'
    assert_select 'label[for=user_reset_password_token]',
                  count: 1,
                  text: 'Veuillez faire une nouvelle demande de changement de mot de passe, cette demande a expirée'
  end
end
