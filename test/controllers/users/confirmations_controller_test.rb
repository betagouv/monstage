# frozen_string_literal: true

require 'test_helper'

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  test 'GET with valid token and not confirmed user' do
    student = create(:student, confirmed_at: nil, confirmation_token: 'abc')
    get user_confirmation_path(confirmation_token: student.confirmation_token)
    assert_redirected_to new_user_session_path(email: student.email)
    follow_redirect!
    assert_select('#alert-success #alert-text', text: 'Votre compte est bien confirmé. Vous pouvez vous connecter.')
  end
end
