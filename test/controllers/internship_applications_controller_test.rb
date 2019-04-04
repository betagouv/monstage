require 'test_helper'

module InternshipApplications
  class IndexTest <  ActionDispatch::IntegrationTest

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

      assert_select "a[href=?]", internship_offer_internship_application_path(internship_offer, internship_application, transition: :reject!), count: 1
      assert_select "a[href=?]", internship_offer_internship_application_path(internship_offer, internship_application, transition: :approve!), count: 1
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

      assert_select "a[href=?]", internship_offer_internship_application_path(internship_offer, internship_application, transition: :reject!), count: 0
      assert_select "a[href=?]", internship_offer_internship_application_path(internship_offer, internship_application, transition: :approve!), count: 0
    end
  end
end
