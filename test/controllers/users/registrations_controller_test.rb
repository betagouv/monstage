require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test 'GET new redirects if no type is chosen' do
    get new_user_registration_path
    assert_redirected_to users_choose_profile_path
  end

  test 'GET choose_profile' do
    get users_choose_profile_path

    assert_select "a[href=?]", "/users/sign_up?as=Student"
    assert_select "a[href=?]", "/users/sign_up?as=Employer"
    assert_select "a[href=?]", "/users/sign_up?as=SchoolManager"
  end

  test 'GET new as a SchoolManager' do
    get new_user_registration_path(as: 'SchoolManager')

    assert_response :success
    assert_select 'input', { value: 'SchoolManager', hidden: 'hidden' }
    assert_select 'label', 'Courriel professionnel'
  end

  test 'GET new as Student render expected inputs' do

    get new_user_registration_path(as: 'Student')

    assert_response :success
    assert_select 'input', { value: 'Student', hidden: 'hidden' }
    assert_select 'input[name="user[school_id]"]'
    assert_select 'input[name="user[first_name]"]'
    assert_select 'input[name="user[last_name]"]'
    assert_select 'input[name="user[birth_date]"]'
    assert_select 'input[name="user[gender]"]'
    assert_select 'input[name="user[email]"]'
    assert_select 'input[name="user[password]"]'
    assert_select 'input[name="user[password_confirmation]"]'
  end

  test 'POST create Student responds with success' do
    school = create(:school)
    birth_date = 14.years.ago
    assert_difference("Student.count") do
      post user_registration_path(
        params: {
          user: {
            type: 'Student',
            school_id: school.id,
            first_name: 'Martin',
            last_name: 'Fourcade',
            birth_date: birth_date,
            gender: 'm',
            email: 'fourcade.m@gmail.com',
            password: 'okokok',
            password_confirmation: 'okokok',
          }
        }
      )
      assert_redirected_to root_path
    end
    created_student = Student.first
    assert_equal school, created_student.school
    assert_equal 'Martin', created_student.first_name
    assert_equal 'Fourcade', created_student.last_name
    assert_equal birth_date.year, created_student.birth_date.year
    assert_equal birth_date.month, created_student.birth_date.month
    assert_equal birth_date.day, created_student.birth_date.day
    assert_equal 'm', created_student.gender
    assert_equal 'fourcade.m@gmail.com', created_student.email
  end

  test 'POST create School Manager responds with success' do
    assert_difference("SchoolManager.count") do
      post user_registration_path(params: { user: { email: 'test@ac-edu.fr',
                                                     password: 'okokok',
                                                     password_confirmation: 'okokok',
                                                     first_name: 'Chef',
                                                     last_name: 'Etablissement',
                                                     type: 'SchoolManager' }})
      assert_redirected_to root_path
    end
  end

  test 'POST Create Student' do
    assert_difference("Student.count") do
      post user_registration_path(params: { user: { email: 'fatou@snapchat.com',
                                                    password: 'okokok',
                                                    password_confirmation: 'okokok',
                                                    first_name: 'Fatou',
                                                    last_name: 'D',
                                                    type: 'Student' }})
      assert_redirected_to root_path
    end
  end

  test 'POST Create Employer' do
    assert_difference("Employer.count") do
      post user_registration_path(params: { user: { email: 'madame@accor.fr',
                                                    password: 'okokok',
                                                    password_confirmation: 'okokok',
                                                    type: 'Employer' }})
      assert_redirected_to root_path
    end
  end
end
