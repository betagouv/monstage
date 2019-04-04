require 'test_helper'

class InternshipApplicationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionMailer::TestHelper

  test "POST #create internship application" do
    internship_offer = create(:internship_offer)
    student = create(:student)
    sign_in(student)
    valid_params = { internship_application: { internship_offer_week_id: internship_offer.internship_offer_weeks.first.id,
                                               motivation: 'Je suis trop motivé wesh',
                                               user_id: student.id
                                             }}
    assert_difference('InternshipApplication.count', 1) do
      post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
      assert_redirected_to internship_offers_path
    end
    assert_enqueued_emails 1


    created_internship_application = InternshipApplication.last
    assert_equal internship_offer.internship_offer_weeks.first.id, created_internship_application.internship_offer_week.id
    assert_equal 'Je suis trop motivé wesh', created_internship_application.motivation
    assert_equal student.id, created_internship_application.student.id
  end

  test "POST #create internship application failed" do
    internship_offer = create(:internship_offer)
    student = create(:student)
    sign_in(student)
    valid_internship_application_params = { internship_offer_week_id: internship_offer.internship_offer_weeks.first.id,
                                               motivation: 'Je suis trop motivé wesh',
                                               user_id: student.id
                                             }

    assert_no_difference('InternshipApplication.count') do
      post(internship_offer_internship_applications_path(internship_offer),
           params: { internship_application: valid_internship_application_params.except(:motivation)})
    end
    assert_redirected_to internship_offer_path(internship_offer)

    assert_no_difference('InternshipApplication.count') do
      post(internship_offer_internship_applications_path(internship_offer),
           params: { internship_application: valid_internship_application_params.except(:internship_offer_week_id)})
    end
    assert_redirected_to internship_offer_path(internship_offer)

    assert_no_difference('InternshipApplication.count') do
      post(internship_offer_internship_applications_path(internship_offer),
           params: { internship_application: valid_internship_application_params.except(:user_id)})
    end
    assert_redirected_to internship_offer_path(internship_offer)
  end

  test "PATCH #update approve application" do
    internship_application = create(:internship_application)

    sign_in(internship_application.internship_offer.employer)

    assert_enqueued_emails 1 do
      patch(internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
            params: { approve: true })
    end

    assert_redirected_to internship_offer_path(internship_application.internship_offer)

    assert InternshipApplication.last.approved?
  end

  test "PATCH #update decline application" do
    internship_application = create(:internship_application)

    sign_in(internship_application.internship_offer.employer)

    assert_enqueued_emails 1 do
      patch(internship_offer_internship_application_path(internship_application.internship_offer, internship_application),
            params: { approve: false })
    end

    assert_redirected_to internship_offer_path(internship_application.internship_offer)

    assert InternshipApplication.last.rejected?
  end

  test "GET #index redirect to new_user_session_path when not logged in" do
    get internship_offer_internship_applications_path(create(:internship_offer))
    assert_redirected_to new_user_session_path
  end

  test "GET #index redirects to root_path when logged in as student" do
    sign_in(create(:student))
    get internship_offer_internship_applications_path(create(:internship_offer))
    assert_redirected_to root_path
  end

  test "GET #index redirects to root_path when logged as different employer than internship_offer.employer" do
    sign_in(create(:employer))
    get internship_offer_internship_applications_path(create(:internship_offer))
    assert_redirected_to root_path
  end

  test "GET #index succeed when logged in as employer, shows default fields, ensure presence of approve and reject links" do
    internship_offer = create(:internship_offer)
    school = create(:school, city: "Paris", name: "Mon collège")
    student = create(:student, school: school,
                               birth_date: 14.years.ago,
                               resume_educational_background: 'resume_educational_background',
                               resume_other: 'resume_other',
                               resume_languages: 'resume_languages',
                               resume_volunteer_work: 'resume_volunteer_work')
    internship_application = create(:internship_application, internship_offer: internship_offer,
                                                             student: student)
    sign_in(internship_offer.employer)
    get internship_offer_internship_applications_path(internship_offer)
    assert_response :success

    assert_select "h2", "Candidature de #{internship_application.student.name} reçu le #{I18n.localize(internship_application.created_at, format: "%d %B")}"
    assert_select ".student-name", student.name
    assert_select ".school-name", school.name
    assert_select ".school-city", school.city
    assert_select ".student-age", "#{student.age}"
    assert_select "pre", student.resume_educational_background
    assert_select "pre", student.resume_other
    assert_select "pre", student.resume_languages
    assert_select "pre", student.resume_volunteer_work

    assert_select "a[href=?]", internship_offer_internship_application_path(internship_offer, internship_application, approve: false), count: 1
    assert_select "a[href=?]", internship_offer_internship_application_path(internship_offer, internship_application, approve: true), count: 1
  end

  test "GET #index with approved offer, does not shows approve/reject link" do
    internship_offer = create(:internship_offer)
    school = create(:school, city: "Paris", name: "Mon collège")
    student = create(:student, school: school,
                               birth_date: 14.years.ago,
                               resume_educational_background: 'resume_educational_background',
                               resume_other: 'resume_other',
                               resume_languages: 'resume_languages',
                               resume_volunteer_work: 'resume_volunteer_work')
    internship_application = create(:internship_application, internship_offer: internship_offer,
                                                             student: student,
                                                             aasm_state: 'approved')
    sign_in(internship_offer.employer)
    get internship_offer_internship_applications_path(internship_offer)
    assert_response :success

    assert_select "a[href=?]", internship_offer_internship_application_path(internship_offer, internship_application, approve: false), count: 0
    assert_select "a[href=?]", internship_offer_internship_application_path(internship_offer, internship_application, approve: true), count: 0
  end
end
