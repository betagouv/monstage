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

  test 'POST create by email' do
    student = create(:student)
    assert_enqueued_emails 1 do
      post user_password_path, params: { user: { channel: :email, email: student.email } }
      assert_redirected_to new_user_session_path
    end
  end

  test 'POST create by phone' do
    student = create(:student, email: nil, phone: '+33637607756')
    assert_enqueued_jobs 1, only: SendSmsJob do
      post user_password_path, params: { user: { channel: :phone, phone: student.phone } }
      assert_redirected_to phone_edit_password_path(phone: student.phone)
    end
  end
end
