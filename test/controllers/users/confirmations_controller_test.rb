# frozen_string_literal: true

require 'test_helper'

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  test 'GET confirmation by email with with valid token and not confirmed user' do
    student = create(:student, confirmed_at: nil, confirmation_token: 'abc')
    get user_confirmation_path(confirmation_token: student.confirmation_token)
    assert_redirected_to new_user_session_path(email: student.email)
    follow_redirect!
    assert_select('#alert-success #alert-text', text: 'Votre compte est bien confirmé. Vous pouvez vous connecter.')
  end

  test 'GET#new_user_confirmation' do
    student = create(:student, confirmed_at: nil)
    get new_user_confirmation_path
    assert_response :success
    assert_select 'title', "Confirmation | Monstage"
  end

  test 'CREATE#user_confirmation by phone with wrong phone' do
    student = create(:student, phone: '+330600110011',
                               email: nil,
                               confirmed_at: nil)
    assert_enqueued_jobs 0, only: SendSmsJob do
      post user_confirmation_path(user: { channel: :phone, phone: '+330699999999' })
    end
    assert_template :new
    assert_select '.fr-alert.fr-alert--error',
                  html: '<strong>Téléphone mobile</strong> : Votre numéro de téléphone est inconnu'
  end

  test 'CREATE#user_confirmation by email' do
    student = create(:employer, phone: nil,
                               email: 'fourcade.m@gmail.com',
                               confirmed_at: nil)
    assert_enqueued_emails 1 do
      post user_confirmation_path(user: { channel: :email, email: student.email })
    end
    assert_redirected_to new_user_session_path
  end
end
