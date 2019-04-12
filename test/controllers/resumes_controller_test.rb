require 'test_helper'

class ResumesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "GET index not logged redirects to sign in" do
    get resume_path
    assert_redirected_to user_session_path
  end

  test "GET index as Student" do
    sign_in(create(:student))
    get resume_path
    assert_template "resumes/edit"
    assert_template "dashboard/_student_navbar"
    assert_select "form[action=?]", resume_path
  end

  test 'PATCH edit as student, updates resume params' do
    student = create(:student)
    sign_in(student)

    patch(resume_path, params: {
                         user: {
                           resume_educational_background: 'background',
                           resume_volunteer_work: 'work',
                           resume_other: 'other',
                           resume_languages: 'languages'
                         }
                       })

    assert_redirected_to resume_path
    student.reload
    assert_equal 'background', student.resume_educational_background
    assert_equal 'work', student.resume_volunteer_work
    assert_equal 'other', student.resume_other
    assert_equal 'languages', student.resume_languages
    follow_redirect!
    assert_select "#alert-success #alert-text", {text: 'Compte mis à jour avec succès'}, 1
  end
end
