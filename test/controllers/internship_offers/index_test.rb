require 'test_helper'

class IndexTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def assert_presence_of(internship_offer:)
    assert_select "[data-test-id=#{internship_offer.id}]", 1
  end

  def assert_absence_of(internship_offer:)
    assert_select "[data-test-id=#{internship_offer.id}]", 0
  end

  test 'GET #index redirect to root_path if not connected' do
    get internship_offers_path
    assert_redirected_to user_session_path
  end

  test 'GET #index as student. check if filters are properly populated' do
    create(:internship_offer, sector: "Animaux")
    create(:internship_offer, sector: "Droit, Justice")
    create(:internship_offer, sector: "Mode, Luxe, Industrie textile")
    student = create(:student)

    sign_in(student)
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        get internship_offers_path

        assert_response :success
        assert_select 'select#internship-offer-sector-filter option', 3
        assert_select 'option', text: "Animaux"
        assert_select 'option', text: "Droit, Justice"
        assert_select 'option', text: "Mode, Luxe, Industrie textile"
      end
    end
  end

  test 'GET #index as student returns internship_offer up to 60km nearby' do
    week = Week.find_by(year: 2019, number: 10)
    school_at_paris = create(:school, :at_paris)
    student = create(:student, school: school_at_paris)
    internship_offer = create(:internship_offer, sector: "Animaux",
                                                 weeks: [week],
                                                 coordinates: Coordinates.paris)

    InternshipOffer.stub :by_weeks, InternshipOffer.all do
      sign_in(student)
      travel_to(Date.new(2019, 3, 1)) do
        get internship_offers_path
        assert_response :success
        assert_presence_of(internship_offer: internship_offer)
      end
    end
  end

  test 'GET #index as student ignores internship_offer farther than 60 km nearby school coordinates' do
    week = Week.find_by(year: 2019, number: 10)
    school_at_bordeaux = create(:school, :at_bordeaux)
    student = create(:student, school: school_at_bordeaux)
    create(:internship_offer, sector: "Animaux", weeks: [week], coordinates: Coordinates.paris)

    InternshipOffer.stub :by_weeks, InternshipOffer.all do
      sign_in(student)
      travel_to(Date.new(2019, 3, 1)) do
        get internship_offers_path

        assert_response :success
        assert_select ".offer-row", 0
      end
    end
  end

  test 'GET #index as student ignores internship_offer not in school.weeks' do
    week = Week.find_by(year: 2019, number: 10)
    school = create(:school, weeks: [week])
    student = create(:student, school: school)
    offer_overlaping_school_weeks = create(:internship_offer, weeks: [week])
    offer_not_overlaping_school_weeks = create(:internship_offer, weeks: [Week.find_by(year: 2019, number: 11)])
    sign_in(student)
    InternshipOffer.stub :nearby, InternshipOffer.all do
      travel_to(Date.new(2019, 3, 1)) do
        get internship_offers_path
        assert_presence_of(internship_offer: offer_overlaping_school_weeks)
        assert_absence_of(internship_offer: offer_not_overlaping_school_weeks)
      end
    end
  end

  test 'GET #index as student ' \
       'ignores internship_offer restricted to school' \
       'finds internship_offer limited to current student school ' \
       'finds all internship_offers not limited' do
    student = create(:student, school: create(:school))
    sign_in(student)

    internship_limited_to_another_school = create(:internship_offer, school: create(:school))
    internship_limited_to_student_school = create(:internship_offer, school: student.school)
    internship_not_restricted_to_school = create(:internship_offer)

    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        get internship_offers_path
        assert_presence_of(internship_offer: internship_not_restricted_to_school)
        assert_presence_of(internship_offer: internship_limited_to_student_school)
        assert_absence_of(internship_offer: internship_limited_to_another_school)
      end
    end
  end

  test 'GET #index as employer returns his internship_offers' do
    employer = create(:employer)
    included_internship_offer = create(:internship_offer, employer: employer, title: 'Hellow-me')
    excluded_internship_offer = create(:internship_offer, title: 'Not hellow-me')
    sign_in(employer)
    get internship_offers_path
    assert_response :success
    assert_presence_of(internship_offer: included_internship_offer)
    assert_absence_of(internship_offer: excluded_internship_offer)
  end

  test 'GET #index as god returns all internship_offers' do
    sign_in(create(:god))
    internship_offer_1 = create(:internship_offer, title: 'Hellow-me')
    internship_offer_2 = create(:internship_offer, title: 'Not hellow-me')
    get internship_offers_path
    assert_response :success
    assert_presence_of(internship_offer: internship_offer_1)
    assert_presence_of(internship_offer: internship_offer_2)
  end

  test 'GET #index as god. does not return discarded offers' do
    discarded_internship_offer = create(:internship_offer, sector: "Animaux")
    discarded_internship_offer.discard
    god = create(:god)

    sign_in(god)
    get internship_offers_path

    assert_response :success
    assert_select "a[href=?]", internship_offer_url(discarded_internship_offer), 0
  end
end
