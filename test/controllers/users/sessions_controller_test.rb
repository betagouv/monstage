# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'GET works and autofocus email' do
    get new_user_session_path
    assert_response :success
    assert_select "#user_email[autofocus=autofocus]"
    assert_select "#user_password[autofocus=autofocus]", count: 0
  end

  test 'GET with prefilled email works' do
    email = 'fourcade.m@gmail.com'
    get new_user_session_path(email: email)
    assert_response :success
    assert_select "#user_email[autofocus=autofocus]", count: 0
    assert_select "#user_email[value=\"#{email}\"]"
    assert_select "#user_password[autofocus=autofocus]"
  end
end
