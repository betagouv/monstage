# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest

  test 'GET works' do
    get new_user_session_path
    assert_response :success
    assert_select "#user_email"
    assert_select "#channel-phone"
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

  test 'POST session not confirmed render warning with icon' do
    pwd = 'okokok'
    student = create(:student, password: pwd, confirmed_at: nil)
    post user_session_path(params: { user: { channel: 'email',
                                             email: student.email,
                                             password: pwd } })
    assert_response :found
    follow_redirect!
    assert_select "#alert-warning #alert-text", text: 'Un message d’activation vous a été envoyé par courrier électronique. Veuillez suivre les instructions qu’il contient.', count: 1
  end

  test 'POST session with phone' do
    pwd = 'okokok'
    phone = "+33637607756"
    student = create(:student, email:nil, phone: phone, password: pwd, confirmed_at: 2.days.ago)
    post user_session_path(params: { user: { channel: 'phone',
                                             phone: student.phone,
                                             password: pwd } })
    assert_response :found
    follow_redirect!
    assert_select "a[href=?]", account_path
  end

  test 'POST session with email' do
    pwd = 'okokok'
    email = 'fourcade.m@gmail.com'
    student = create(:student, email: email, phone: nil, password: pwd, confirmed_at: 2.days.ago)
    post user_session_path(params: { user: { channel: 'email',
                                             phone: student.email,
                                             password: pwd } })
    assert_response :found
    follow_redirect!
    assert_select "a[href=?]", account_path
  end
end
