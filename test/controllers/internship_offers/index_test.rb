# frozen_string_literal: true

require 'test_helper'

class IndexTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ::ApiTestHelpers

  def assert_presence_of(internship_offer:)
    assert_select "[data-test-id=#{internship_offer.id}]", 1
  end

  def assert_absence_of(internship_offer:)
    assert_select "[data-test-id=#{internship_offer.id}]", 0
  end

  test 'GET #index as "Users::Visitor" works' do
    get internship_offers_path
    assert_response :success
  end

  test 'GET #index with coordinates as "Users::Visitor" works' do
    get internship_offers_path(latitude: 44.8378, longitude: -0.579512)
    assert_response :success
  end

  test 'GET #index as student ignores internship_offers with existing applicaiton' do
    internship_offer_without_application = create(:internship_offer, title: 'ok')
    school = create(:school, weeks: internship_offer_without_application.weeks)
    student = create(:student, school: school, class_room: create(:class_room, :troisieme_generale, school: school))
    internship_offer_with_application = create(:internship_offer, title: 'o', weeks: internship_offer_without_application.weeks)
    internship_application = create(:internship_application, {
      student: student,
      internship_offer_week: internship_offer_with_application.internship_offer_weeks.first
    })

    sign_in(student)
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        get internship_offers_path
        assert_absence_of(internship_offer: internship_offer_with_application)
        assert_presence_of(internship_offer: internship_offer_without_application)
      end
    end
  end

  test 'GET #index as statistician works' do
    statistician = create(:statistician)
    sign_in(statistician)
    get internship_offers_path
    assert_response :success
  end

  test 'GET #index as student. ignores internship offers not published' do
    internship_offer_published = create(:internship_offer)
    internship_offer_unpublished = create(:internship_offer)
    internship_offer_unpublished.update_column(:published_at, nil)
    student = create(:student)
    sign_in(student)
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        get internship_offers_path
        assert_absence_of(internship_offer: internship_offer_unpublished)
        assert_presence_of(internship_offer: internship_offer_published)
      end
    end
  end

  test 'GET #index as student when school.weeks is empty, shows warning' do
    school = create(:school, weeks: [])
    student = create(:student, school: school)
    sign_in(student)
    get internship_offers_path
    assert_select "#alert-text", text: "Attention, votre établissement n'a pas encore renseigné ses dates de stages. Nous affichons des offres qui pourraient ne pas correspondre à vos dates.",
                                 count: 1
  end

  test 'GET #index as visitor when school.weeks is empty, shows warning' do
    get internship_offers_path
    assert_select "#alert-text", text: "Attention, votre établissement n'a pas encore renseigné ses dates de stages. Nous affichons des offres qui pourraient ne pas correspondre à vos dates.",
                                 count: 0
  end

  test 'GET #index as visitor does not show discarded offers' do
    discarded_internship_offer = create(:internship_offer, discarded_at: 2.days.ago)
    not_discarded_internship_offer = create(:internship_offer, discarded_at: nil)
    get internship_offers_path
    assert_presence_of(internship_offer: not_discarded_internship_offer)
    assert_absence_of(internship_offer: discarded_internship_offer)
  end

  test 'GET #index as visitor does not show unpublished offers' do
    published_internship_offer = create(:internship_offer, published_at: 2.days.ago)
    not_published_internship_offer = create(:internship_offer)
    not_published_internship_offer.update!(published_at: nil)
    get internship_offers_path
    assert_presence_of(internship_offer: published_internship_offer)
    assert_absence_of(internship_offer: not_published_internship_offer)
  end

  test 'GET #index as visitor default shows both middle school and high school offers' do
    internship_offer_weekly = create(:internship_offer, title: 'middle_school offer')
    internship_offer_free   = create(:free_date_internship_offer, title: 'high_school offer')
    get internship_offers_path
    assert_presence_of(internship_offer: internship_offer_weekly)
    assert_presence_of(internship_offer: internship_offer_free)
    assert true
  end

  test 'GET #index as student. ignores internship offers with blocked_weeks_count > internship_offer_weeks_count' do
    internship_offer_with_max_internship_offer_weeks_count_reached = create(:internship_offer, weeks: [Week.first, Week.last], blocked_weeks_count: 2)
    internship_offer_without_max_internship_offer_weeks_count_reached = create(:internship_offer, weeks: [Week.first, Week.last], blocked_weeks_count: 0)
    school = create(:school)
    student = create(:student, school: school, class_room: create(:class_room, :troisieme_generale, school: school))
    sign_in(student)
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        get internship_offers_path
        assert_absence_of(internship_offer: internship_offer_with_max_internship_offer_weeks_count_reached)
        assert_presence_of(internship_offer: internship_offer_without_max_internship_offer_weeks_count_reached)
      end
    end
  end

  test 'GET #index ignores internship_offers having ' \
       'as much internship_application as max_candidates number' do
    max_candidates = 1
    week = Week.first
    school = create(:school)
    student = create(:student, school: school, class_room: create(:class_room, :troisieme_generale, school: school))
    internship_offer = create(:internship_offer,
                              max_candidates: max_candidates,
                              internship_offer_weeks: [
                                build(:internship_offer_week, blocked_applications_count: max_candidates,
                                                              week: Week.first)
                              ])
    sign_in(student)
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        get internship_offers_path
        assert_absence_of(internship_offer: internship_offer)
      end
    end
  end

  test 'GET #index keeps internship_offers having ' \
       'as less than blocked_applications_count as max_candidates number' do
    max_candidates = 2
    internship_offer = create(:internship_offer,
                              max_candidates: max_candidates,
                              internship_offer_weeks: [
                                build(:internship_offer_week, blocked_applications_count: max_candidates - 1,
                                                              week: Week.first)
                              ])
    sign_in(create(:student))
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        get internship_offers_path
        assert_presence_of(internship_offer: internship_offer)
      end
    end
  end

  test 'GET #index finds internship_offers available with one week that is not available' do
    max_candidates = 1
    internship_weeks = [Week.first, Week.last]
    school = create(:school, weeks: internship_weeks)
    blocked_internship_week = build(:internship_offer_week, blocked_applications_count: max_candidates,
                                                            week: internship_weeks[0])
    not_blocked_internship_week = build(:internship_offer_week, blocked_applications_count: 0,
                                                                week: internship_weeks[1])
    internship_offer = create(:internship_offer, max_candidates: max_candidates,
                                                 internship_offer_weeks: [blocked_internship_week,
                                                                          not_blocked_internship_week])
    sign_in(create(:student, school: school))
    InternshipOffer.stub :nearby, InternshipOffer.all do
      get internship_offers_path
      assert_presence_of(internship_offer: internship_offer)
    end
  end

  test 'GET #index ignores internship_offers not blocked on different week that is not available' do
    max_candidates = 1
    internship_weeks = [Week.first, Week.last]
    school = create(:school, weeks: [internship_weeks[0]])
    blocked_internship_week = build(:internship_offer_week, blocked_applications_count: max_candidates,
                                                            week: internship_weeks[0])
    not_blocked_internship_week = build(:internship_offer_week, blocked_applications_count: 0,
                                                                week: internship_weeks[1])
    internship_offer = create(:internship_offer, max_candidates: max_candidates,
                                                 internship_offer_weeks: [blocked_internship_week,
                                                                          not_blocked_internship_week])

    sign_in(create(:student, school: school,
                             class_room: create(:class_room, :troisieme_generale, school: school)))

    InternshipOffer.stub :nearby, InternshipOffer.all do
      get internship_offers_path
      assert_absence_of(internship_offer: internship_offer)
    end
  end

  test 'GET #index finds internship_offers blocked on other weeks' do
    max_candidates = 1
    internship_weeks = [Week.first, Week.last]
    school = create(:school, weeks: [internship_weeks[1]])
    blocked_internship_week = build(:internship_offer_week, blocked_applications_count: max_candidates,
                                                            week: internship_weeks[0])
    not_blocked_internship_week = build(:internship_offer_week, blocked_applications_count: 0,
                                                                week: internship_weeks[1])
    internship_offer = create(:internship_offer, max_candidates: max_candidates,
                                                 internship_offer_weeks: [blocked_internship_week,
                                                                          not_blocked_internship_week])

    sign_in(create(:student, school: school))

    InternshipOffer.stub :nearby, InternshipOffer.all do
      get internship_offers_path
      assert_presence_of(internship_offer: internship_offer)
    end
  end

  test 'GET #index as student with page, returns paginated content' do
    internship_offers = (InternshipOffer::PAGE_SIZE + 1)
                          .times
                          .map { create(:internship_offer, max_candidates: 2) }

    travel_to(Date.new(2019, 3, 1)) do
      sign_in(create(:student))
      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          InternshipOffer.stub :in_the_future, InternshipOffer.all do
            get internship_offers_path
            assert_presence_of(internship_offer: internship_offers.last)
            assert_absence_of(internship_offer: internship_offers.first)

            get internship_offers_path(page: 2)
            assert_presence_of(internship_offer: internship_offers.first)
            assert_absence_of(internship_offer: internship_offers.last)
          end
        end
      end
    end
  end

  test 'GET #index as student with InternshipOffers::Api, returns paginated content' do
    internship_offers = (InternshipOffer::PAGE_SIZE + 1).times.map { create(:api_internship_offer) }
    travel_to(Date.new(2019, 3, 1)) do
      sign_in(create(:student))
      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          InternshipOffer.stub :in_the_future, InternshipOffer.all do
            get internship_offers_path
            assert_presence_of(internship_offer: internship_offers.last)
            assert_absence_of(internship_offer: internship_offers.first)

            get internship_offers_path page: 2
            assert_presence_of(internship_offer: internship_offers.first)
            assert_absence_of(internship_offer: internship_offers.last)
          end
        end
      end
    end
  end

  test 'GET #index as student with latitude/longitude ' \
       'includes latitude/longitude for listable behaviour on show page' do
    sign_in(create(:student))
    internship_1 = create(:internship_offer)
    internship_2 = create(:internship_offer)

    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        get internship_offers_path, params: { latitude: 1, longitude: 1 }
        assert_select("a[href=?]", internship_offer_path(id: internship_1, latitude: 1, longitude: 1))
      end
    end
  end

  test 'GET #index?latitude=?&longitude=? as student returns internship_offer 60km around this location' do
    week = Week.find_by(year: 2019, number: 10)
    school_at_paris = create(:school, :at_paris)
    student = create(:student, school: school_at_paris)
    internship_offer_at_paris = create(:internship_offer,
                                       weeks: [week],
                                       coordinates: Coordinates.paris)
    internship_offer_at_bordeaux = create(:internship_offer,
                                          weeks: [week],
                                          coordinates: Coordinates.bordeaux)

    InternshipOffer.stub :by_weeks, InternshipOffer.all do
      sign_in(student)
      travel_to(Date.new(2019, 3, 1)) do
        get internship_offers_path(latitude: Coordinates.bordeaux[:latitude],
                                   longitude: Coordinates.bordeaux[:longitude])
        assert_response :success
        assert_absence_of(internship_offer: internship_offer_at_paris)
        assert_presence_of(internship_offer: internship_offer_at_bordeaux)
      end
    end
  end

  test 'GET #index as student ignores internship_offer farther than 60 km nearby school coordinates' do
    week = Week.find_by(year: 2019, number: 10)
    school_at_bordeaux = create(:school, :at_bordeaux)
    student = create(:student, school: school_at_bordeaux)
    create(:internship_offer, weeks: [week], coordinates: Coordinates.paris)

    InternshipOffer.stub :by_weeks, InternshipOffer.all do
      sign_in(student)
      travel_to(Date.new(2019, 3, 1)) do
        get internship_offers_path

        assert_response :success
        assert_select '.offer-row', 0
      end
    end
  end

  test 'GET #index as student ignores internship_offer not in school.weeks' do
    week = Week.find_by(year: 2019, number: 10)
    school = create(:school, weeks: [week])
    student = create(:student, school: school, class_room: create(:class_room, :troisieme_generale, school: school))
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

  #
  # Employer
  #
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

  #
  # Operator
  #
  test 'GET #index as operator having departement-constraint only return internship offer with location constraint' do
    operator = create(:operator)
    user_operator = create(:user_operator, operator: operator, department_name: 'Oise')
    included_internship_offer = create(:internship_offer,
                                        employer: user_operator,
                                        zipcode: 60580
                                      )
    excluded_internship_offer = create(:internship_offer,
                                        employer: user_operator,
                                        zipcode: 95270
                                      )
    sign_in(user_operator)
    get internship_offers_path
    assert_response :success
    assert_presence_of(internship_offer: included_internship_offer)
    assert_absence_of(internship_offer: excluded_internship_offer)
  end

  test 'GET #index as operator not departement-constraint returns internship offer not considering location constraint' do
    operator = create(:operator)
    user_operator = create(:user_operator, operator: operator, department_name: nil)
    included_internship_offer = create(:internship_offer,
                                        employer: user_operator,
                                        zipcode: 60580
                                      )
    excluded_internship_offer = create(:internship_offer,
                                        employer: user_operator,
                                        zipcode: 95270
                                      )
    sign_in(user_operator)
    get internship_offers_path
    assert_response :success
    assert_presence_of(internship_offer: included_internship_offer)
    assert_presence_of(internship_offer: excluded_internship_offer)
  end

  test 'GET #index as operator can filter by coordinates' do
    operator = create(:operator)
    user_operator = create(:user_operator, operator: operator, department_name: nil)
    excluded_internship_offer = create(:internship_offer, employer: user_operator,
                                                          coordinates: Coordinates.paris)
    included_internship_offer = create(:internship_offer, employer: user_operator,
                                                          coordinates: Coordinates.bordeaux)
    sign_in(user_operator)
    get internship_offers_path(latitude: Coordinates.bordeaux[:latitude],
                               longitude: Coordinates.bordeaux[:longitude])
    assert_response :success
    assert_presence_of(internship_offer: included_internship_offer)
    assert_absence_of(internship_offer: excluded_internship_offer)
  end

  test "GET #index lists offers that an operator's colleague has created" do
    operator = create(:operator)
    user_operator_1 = create(:user_operator, operator: operator, department_name: nil)
    user_operator_2 = create(:user_operator, operator: operator, department_name: nil)
    internship_offer_1 = create(:internship_offer, employer: user_operator_1)
    internship_offer_2 = create(:internship_offer, employer: user_operator_2)
    sign_in(user_operator_1)
    get internship_offers_path
    assert_response :success
    assert_presence_of(internship_offer: internship_offer_1)
    assert_presence_of(internship_offer: internship_offer_2)
  end

  test "GET #index does not list offers that another operator has created" do
    operator_1 = create(:operator)
    operator_2 = create(:operator)
    user_operator_1 = create(:user_operator, operator: operator_1, department_name: nil)
    user_operator_2 = create(:user_operator, operator: operator_2, department_name: nil)
    internship_offer_1 = create(:internship_offer,
                                employer: user_operator_1,
                                zipcode: 95270)
    internship_offer_2 = create(:internship_offer,
                                employer: user_operator_2,
                                zipcode: 95270)
    sign_in(user_operator_1)
    get internship_offers_path
    assert_response :success
    assert_presence_of(internship_offer: internship_offer_1)
    assert_absence_of(internship_offer: internship_offer_2)
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
    discarded_internship_offer = create(:internship_offer)
    discarded_internship_offer.discard
    god = create(:god)

    sign_in(god)
    get internship_offers_path

    assert_response :success
    assert_select 'a[href=?]', internship_offer_url(discarded_internship_offer), 0
  end

  test 'GET #index as Visitor with search keyword find internship offer' do
    keyword = "foobar"
    foundable_internship_offer = create(:internship_offer, title: keyword)
    ignored_internship_offer = create(:internship_offer, title: 'bom')

    dictionnary_api_call_stub
    SyncInternshipOfferKeywordsJob.perform_now

    get internship_offers_path(keyword: keyword)
    assert_response :success
    assert_presence_of(internship_offer: foundable_internship_offer)
    assert_absence_of(internship_offer: ignored_internship_offer)
  end
end
