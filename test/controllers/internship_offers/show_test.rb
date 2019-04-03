require 'test_helper'

module InternshipOffers
  class ShowTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #show displays application form for student' do
      sign_in(create(:student))
      get internship_offer_path(create(:internship_offer))

      assert_response :success
      assert_select "form[id=?]", "new_internship_application"
    end

    test 'GET #show website url when present' do
      internship_offer = create(:internship_offer, employer_website: 'http://google.com')
      get internship_offer_path(internship_offer)

      assert_response :success
      assert_select "a.external[href=?]", internship_offer.employer_website
    end

    test 'GET #show does not show website url when absent' do
      internship_offer = create(:internship_offer, employer_website: nil)
      get internship_offer_path(internship_offer)

      assert_response :success
      assert_select "a.external", 0
    end

    test "GET #show as a student who can apply" do
      internship_offer = create(:internship_offer)
      sign_in(create(:student))

      get internship_offer_path(internship_offer)

      assert_select "#new_internship_application", 1
    end

    test "GET #show as a student should display only weeks that matches school weeks" do
      internship_offer = create(:internship_offer)
      weeks = [Week.first, Week.last]
      internship_offer.weeks = weeks
      internship_offer.save

      student = create(:student)
      sign_in(student)

      student.school.weeks = [Week.first]

      get internship_offer_path(internship_offer)

      assert_select 'select[name="internship_application[internship_offer_week_id]"] option',
                    weeks.size
    end

    test "GET #show as a student should display only weeks that are not blocked" do
      max_candidates = 2
      weeks_available = [Week.all[0], Week.all[1]]
      blocked_internship_week = build(:internship_offer_week, blocked_applications_count: max_candidates,
                                                              week: weeks_available[0])
      available_internship_week = build(:internship_offer_week, blocked_applications_count: 0,
                                                                week: weeks_available[1])

      internship_offer = create(:internship_offer,
                                max_candidates: max_candidates,
                                internship_offer_weeks: [
                                  blocked_internship_week,
                                  available_internship_week
                                ])

      student = create(:student)
      sign_in(student)

      student.school.weeks = [Week.first]

      get internship_offer_path(internship_offer)

      assert_select 'select[name="internship_application[internship_offer_week_id]"] option',
                    1
    end
  end
end
