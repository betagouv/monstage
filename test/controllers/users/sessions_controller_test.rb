# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'GET works' do
    get new_user_session_path
    assert_response :success
    assert_select 'title', "Connexion | Monstage"
    assert_select '#user_email'
    assert_select '#select-channel-phone'
    assert_select '#user_password[autofocus=autofocus]', count: 0
  end

  test 'GET #new_session with check_confirmation and id params and unconfirmed account' do
    email = 'fourcade.m@gmail.com'
    employer = create(:employer, email: email, confirmed_at: nil)
    get new_user_session_path(params:{check_confirmation: true, id: employer.id})
    follow_redirect!
    assert_response :success
    assert_select('.h2', text: '1 . Activez votre compte !')
    flash_message = 'Vous trouverez parmi vos emails le message' \
                      ' permettant l\'activation de votre compte'
    assert_select('span#alert-text', text: flash_message) # 1
  end

  test 'GET #new_session with check_confirmation and id params and confirmed account' do
    email = 'fourcade.m@gmail.com'
    employer = create(:employer, email: email, confirmed_at: nil)
    employer.confirm
    get new_user_session_path(params:{check_confirmation: true, id: employer.id})
    assert_response :success
    assert_select('h1', text: 'Connexion à monstagedetroisième.fr')
  end

  test 'GET with prefilled email works' do
    email = 'fourcade.m@gmail.com'
    get new_user_session_path(email: email)
    assert_response :success
    assert_select '#user_email[autofocus=autofocus]', count: 0
    assert_select "#user_email[value=\"#{email}\"]"
    assert_select '#user_password[autofocus=autofocus]'
  end

  test 'POST session not confirmed render warning with icon' do
    pwd = 'okokok'
    student = create(:student, password: pwd, confirmed_at: nil)
    post user_session_path(params: { user: { channel: 'email',
                                             email: student.email,
                                             password: pwd } })
    assert_response :found
    follow_redirect!
    assert_select '#alert-warning #alert-text', text: 'Un message d’activation vous a été envoyé par courrier électronique. Veuillez suivre les instructions qu’il contient.', count: 1
  end

  test 'POST session with phone' do
    pwd = 'okokok'
    phone = '+330637607756'
    student = create(:student, email: nil, phone: phone, password: pwd, confirmed_at: 2.days.ago)
    post user_session_path(params: { user: { channel: 'phone',
                                            phone: student.phone,
                                            password: pwd } })
    assert_response :found
    follow_redirect!
    assert_select 'a[href=?]', account_path
  end

  test 'POST session with email' do
    pwd = 'okokok'
    email = 'fourcade.m@gmail.com'
    student = create(:student, email: email, phone: nil, password: pwd, confirmed_at: 2.days.ago)
    post user_session_path(params: { user: { channel: 'email',
                                             email: student.email,
                                             password: pwd } })
    assert_response :found
    follow_redirect!
    assert_select 'a[href=?]', account_path
  end

  test 'POST session as EMPLOYER with email and check after sign in path when pending applications' do
    pwd = 'okokok'
    email = 'employer@corp.com'
    employer = create(:employer, email: email, phone: nil, password: pwd, confirmed_at: 2.days.ago)
    internship_offer = create(:weekly_internship_offer, employer: employer)
    create(:weekly_internship_application, :submitted, internship_offer: internship_offer)

    post user_session_path(params: { user: { channel: 'email',
                                             email: employer.email,
                                             password: pwd } })
    
    assert_redirected_to dashboard_candidatures_path
  end

  test 'POST session as EMPLOYER with email and check after sign in path when no pending applications' do
    pwd = 'okokok'
    email = 'employer@corp.com'
    employer = create(:employer, email: email, phone: nil, password: pwd, confirmed_at: 2.days.ago)

    post user_session_path(params: { user: { channel: 'email',
                                             email: employer.email,
                                             password: pwd } })
    
    assert_redirected_to dashboard_internship_offers_path
  end


  test 'GET #index as Student with a pending internship_application' do
    student = create(:student, password: 'okokok1Max!!')
    internship_offer = create(:weekly_internship_offer)
    internship_application = create(:weekly_internship_application, :validated_by_employer,
          student: student,
          internship_offer: internship_offer)

    post user_session_path(params: { user: { channel: 'email',
                                              email: student.email,
                                              password: 'okokok1Max!!' } })

                                              follow_redirect!
    assert_response :success
    assert response.body.include? 'Une de vos candidatures a été acceptée'
    assert_select 'a[href=?]', dashboard_students_internship_application_path(student_id: student.id, id: internship_application.id), 1
  end

  test 'lock account' do
    right_password = 'polishThis1Holly!'
    wrong_password = 'piloshThis1Holly!'
    student = create(:student, password: right_password, confirmed_at: nil)
    email = student.email

    post user_session_path(params: { user: { channel: 'email', email: email, password: wrong_password } })
    assert_response :success
    # assert_select 'p#text-input-error-desc-error-email',
    #               text: 'Adresse électronique ou mot de passe incorrects',
    #               count: 1
    assert_equal 1, student.reload.failed_attempts
    max_attempts = Devise.maximum_attempts

    (max_attempts - 2).times do
      post user_session_path(params: { user: { channel: 'email', email: email, password: wrong_password } })
    end
    assert_select("span#alert-text", text: 'Il vous reste une tentative avant que votre compte ne soit bloqué.', count: 1)
    assert_equal max_attempts-1, student.reload.failed_attempts

    post user_session_path(params: { user: { channel: 'email', email: email, password: wrong_password } })
    assert_equal max_attempts, student.reload.failed_attempts
    assert student.reload.access_locked?
  end

  test 'unlocking account sends an email' do
    student = create(:student)
    email = student.email

    student.lock_access!

    post user_unlock_path(params: {user: { email: email }})
    assert_redirected_to new_user_session_path

    # using inside's Devise magics
        raw, enc = Devise.token_generator.generate(User, :unlock_token)
        student.update_columns(unlock_token: enc)
    # using inside's Devise magics end
    get user_unlock_path(unlock_token: raw)
    assert_redirected_to new_user_session_path
    refute student.reload.access_locked?
  end
end
