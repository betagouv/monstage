require 'test_helper'

class IndexTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'GET #index as student. check if filters are properly populated' do
    week = Week.find_by(year: 2019, number: 10)
    create(:internship_offer, sector: "Animaux", weeks: [week])
    create(:internship_offer, sector: "Droit, Justice", weeks: [week])
    create(:internship_offer, sector: "Mode, Luxe, Industrie textile", weeks: [week])
    student = create(:student)

    sign_in(student)
    travel_to(Date.new(2019, 3, 1)) do
      get internship_offers_path

      assert_response :success
      assert_select 'select#internship-offer-sector-filter option', 3
      assert_select 'option', text: "Animaux"
      assert_select 'option', text: "Droit, Justice"
      assert_select 'option', text: "Mode, Luxe, Industrie textile"
    end
  end

  test 'GET #index as student returns internship_offer up to 60km nearby' do
    week = Week.find_by(year: 2019, number: 10)
    school_at_paris = create(:school, :at_paris)
    student = create(:student, school: school_at_paris)
    create(:internship_offer, sector: "Animaux",
                              weeks: [week],
                              coordinates: Coordinates.paris)

    sign_in(student)
    travel_to(Date.new(2019, 3, 1)) do
      get internship_offers_path

      assert_response :success
      assert_select ".offer-row", 1
    end
  end

  test 'GET #index as student ignores internship_offer farther than 60 km nearby school coordinates' do
    week = Week.find_by(year: 2019, number: 10)
    school_at_bordeaux = create(:school, :at_bordeaux)
    student = create(:student, school: school_at_bordeaux)
    create(:internship_offer, sector: "Animaux", weeks: [week], coordinates: Coordinates.paris)

    sign_in(student)
    travel_to(Date.new(2019, 3, 1)) do
      get internship_offers_path

      assert_response :success
      assert_select ".offer-row", 0
    end
  end

  test 'GET #index as employer returns his internship_offers' do
    employer = create(:employer)
    included_internship_offer = create(:internship_offer, employer: employer, title: 'Hellow-me')
    excluded_internship_offer = create(:internship_offer, title: 'Not hellow-me')
    sign_in(employer)
    get internship_offers_path
    assert_response :success
    assert_select 'h3', text: included_internship_offer.title, count: 1
    assert_select 'h3', text: excluded_internship_offer.title, count: 0
  end
end
