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

    test "GET #show as a student displays weeks that matches school weeks" do
      internship_weeks = [Week.find_by(number: 1, year: 2020),
                          Week.find_by(number: 2, year: 2020),
                          Week.find_by(number: 3, year: 2020),
                          Week.find_by(number: 4, year: 2020)]
      school = create(:school, weeks: [internship_weeks[1], internship_weeks[2]])
      internship_offer = create(:internship_offer, weeks: internship_weeks)
      sign_in(create(:student, school: school))

      get internship_offer_path(internship_offer)

      assert_select 'select option', text: internship_weeks[0].select_text_method, count: 0
      assert_select 'select option', text: internship_weeks[1].select_text_method, count: 1
      assert_select 'select option', text: internship_weeks[2].select_text_method, count: 1
      assert_select 'select option', text: internship_weeks[3].select_text_method, count: 0
    end

    test "GET #show as a student displays only weeks that are not blocked" do
      max_candidates = 2
      internship_weeks = [Week.find_by(number: 1, year: 2020),
                          Week.find_by(number: 2, year: 2020)]
      school = create(:school, weeks: internship_weeks)
      blocked_internship_week = build(:internship_offer_week, blocked_applications_count: max_candidates,
                                                              week: internship_weeks[0])
      available_internship_week = build(:internship_offer_week, blocked_applications_count: 0,
                                                                week: internship_weeks[1])
      internship_offer = create(:internship_offer, max_candidates: max_candidates,
                                                   internship_offer_weeks: [ blocked_internship_week,
                                                                             available_internship_week])
      sign_in(create(:student, school: school))
      get internship_offer_path(internship_offer)

      assert_select 'select option', text: blocked_internship_week.week.select_text_method, count: 0
      assert_select 'select option', text: available_internship_week.week.select_text_method, count: 1
    end
  end
end
