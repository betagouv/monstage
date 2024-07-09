require 'application_system_test_case'

class SchoolsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'cannot add favorite as a visitor' do
    create(:weekly_internship_offer)
    visit internship_offers_path
    find("h2 .strong", text: "1 Offre de stage")
    assert_no_selector('.results-col .heart-empty')
  end

  test 'cannot add favorite as a employer' do
    employer = create(:employer)
    sign_in(employer)
    create(:weekly_internship_offer)
    visit internship_offers_path
    find("h2 .strong", text: "1 Offre de stage")
    assert_no_selector('.results-col .heart-empty')
  end

  test 'can add favorite as a student' do
    internship_offer = create(:weekly_internship_offer)
    student = create(:student)
    sign_in student
    visit internship_offers_path
    find("h2 .strong", text: "1 Offre de stage")
    assert_changes -> { Favorite.all.count }, from: 0, to: 1 do
      find(".results-col .heart-empty").click
      find(".results-col .heart-full")
    end
    favorite = Favorite.first
    assert_equal favorite.internship_offer, internship_offer
    assert_equal favorite.user, student
    assert_changes -> { Favorite.all.count }, from: 1, to: 0 do
      find(".results-col .heart-full").click
      find(".results-col .heart-empty")
    end
    assert_changes -> { Favorite.all.count }, from: 0, to: 1 do
      find(".results-col .heart-empty").click
      find(".results-col .heart-full")
    end
  end
end