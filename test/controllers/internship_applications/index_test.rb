require 'test_helper'

module InternshipApplications
  class IndexTest <  ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    def assert_has_link_count_to_transition(internship_application, transition, count)
      internship_offer = internship_application.internship_offer
      assert_select "a[href=?]",
                    internship_offer_internship_application_path(internship_offer,
                                                                 internship_application,
                                                                 transition: transition),
                    count: count
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

    test "GET #index succeed when logged in as employer, shows default fields" do
      school = create(:school, city: "Paris", name: "Mon collège")
      student = create(:student, school: school,
                                 birth_date: 14.years.ago,
                                 resume_educational_background: 'resume_educational_background',
                                 resume_other: 'resume_other',
                                 resume_languages: 'resume_languages',
                                 resume_volunteer_work: 'resume_volunteer_work')
      internship_application = create(:internship_application, student: student)
      sign_in(internship_application.internship_offer.employer)
      get internship_offer_internship_applications_path(internship_application.internship_offer)
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
    end

    test "GET #index with submitted offer, shows approve/reject links" do
      internship_application = create(:internship_application, aasm_state: 'submitted')
      sign_in(internship_application.internship_offer.employer)
      get internship_offer_internship_applications_path(internship_application.internship_offer)
      assert_response :success

      assert_has_link_count_to_transition(internship_application, :approve!, 1)
      assert_has_link_count_to_transition(internship_application, :reject!, 1)
      assert_has_link_count_to_transition(internship_application, :cancel!, 0)
      assert_has_link_count_to_transition(internship_application, :signed!, 0)
    end

    test "GET #index with approved offer, shows cancel! & signed! links" do
      internship_application = create(:internship_application, aasm_state: 'approved')
      sign_in(internship_application.internship_offer.employer)
      get internship_offer_internship_applications_path(internship_application.internship_offer)
      assert_response :success

      assert_has_link_count_to_transition(internship_application, :approve!, 0)
      assert_has_link_count_to_transition(internship_application, :reject!, 0)
      assert_has_link_count_to_transition(internship_application, :cancel!, 1)
      assert_has_link_count_to_transition(internship_application, :signed!, 1)
    end

    test "GET #index with rejected offer, does not shows any link" do
      internship_application = create(:internship_application, aasm_state: 'rejected')
      sign_in(internship_application.internship_offer.employer)
      get internship_offer_internship_applications_path(internship_application.internship_offer)
      assert_response :success
      assert_has_link_count_to_transition(internship_application, :approve!, 0)
      assert_has_link_count_to_transition(internship_application, :reject!, 0)
      assert_has_link_count_to_transition(internship_application, :cancel!, 0)
      assert_has_link_count_to_transition(internship_application, :signed!, 0)
    end

    test "GET #index with convention_signed offer, does not shows any link" do
      internship_application = create(:internship_application, aasm_state: 'convention_signed')
      sign_in(internship_application.internship_offer.employer)
      get internship_offer_internship_applications_path(internship_application.internship_offer)
      assert_response :success
      assert_has_link_count_to_transition(internship_application, :approve!, 0)
      assert_has_link_count_to_transition(internship_application, :reject!, 0)
      assert_has_link_count_to_transition(internship_application, :cancel!, 0)
      assert_has_link_count_to_transition(internship_application, :signed!, 0)
    end
  end
end
