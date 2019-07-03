# frozen_string_literal: true

require 'test_helper'

module InternshipOffers
  class ShowTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    #
    # content checks
    #
    test 'GET #show website url when present' do
      internship_offer = create(:internship_offer, employer_website: 'http://google.com')
      get internship_offer_path(internship_offer)

      assert_response :success
      assert_select 'a.external.test-employer-website[href=?]', internship_offer.employer_website
    end

    test 'GET #show does not show website url when absent' do
      internship_offer = create(:internship_offer, employer_website: nil)
      get internship_offer_path(internship_offer)

      assert_response :success
      assert_select 'a.external.test-employer-website', 0
    end

    #
    # internship_applications checks
    #
    test 'GET #show displays application form for student' do
      student = create(:student)
      sign_in(student)
      get internship_offer_path(create(:internship_offer))

      assert_response :success
      assert_select 'form[id=?]', 'new_internship_application'
      assert_select "input[type=hidden][name='internship_application[user_id]'][value=#{student.id}]"
    end

    test 'GET #show displays application form for main_teacher when internship_offer is reserved to school' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, class_room: class_room, school: school)

      sign_in(school.school_manager)
      get internship_offer_path(create(:internship_offer, school: school))

      assert_response :success
      assert_select 'form[id=?]', 'new_internship_application'
      assert_select 'select[id=internship_application_user_id]'
    end

    test 'GET #show does not display application form for main_teacher when internship_offer is not reserved to school' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, class_room: class_room, school: school)
      main_teacher = create(:main_teacher, class_room: class_room, school: school)

      sign_in(main_teacher)
      get internship_offer_path(create(:internship_offer))

      assert_response :success
      assert_select 'form[id=?]', 'new_internship_application', count: 0
    end

    test 'GET #show as a student who can apply shows an enabled button with candidate label' do
      weeks = [Week.find_by(number: 1, year: 2020)]
      internship_offer = create(:internship_offer, weeks: weeks)
      sign_in(create(:student, school: create(:school, weeks: weeks)))

      get internship_offer_path(internship_offer)
      assert_select '#new_internship_application', 1
      assert_select 'option', text: weeks.first.human_select_text_method, count: 1
      assert_select 'a[href=?]', '#internship-application-form', count: 1
    end

    test 'GET #show as a student who can apply to limited internship offer shows a disabled button with contact SchoolManager label' do
      weeks = [Week.find_by(number: 1, year: 2020)]
      student = create(:student, school: create(:school, weeks: weeks))
      internship_offer = create(:internship_offer, school: student.school, weeks: weeks)
      sign_in(student)
      get internship_offer_path(internship_offer)

      assert_select '.alert.alert-info', text: "Ce stage est reservé au #{internship_offer.school}, afin de candidater prenez contact avec votre chef d'etablissement",
                                         count: 1
      assert_select '#new_internship_application', 0
    end

    test 'GET #show as a student displays weeks that matches school weeks' do
      internship_weeks = [Week.find_by(number: 1, year: 2020),
                          Week.find_by(number: 2, year: 2020),
                          Week.find_by(number: 3, year: 2020),
                          Week.find_by(number: 4, year: 2020)]
      school = create(:school, weeks: [internship_weeks[1], internship_weeks[2]])
      internship_offer = create(:internship_offer, weeks: internship_weeks)
      sign_in(create(:student, school: school))

      get internship_offer_path(internship_offer)

      assert_select 'select option', text: internship_weeks[0].human_select_text_method, count: 0
      assert_select 'select option', text: internship_weeks[1].human_select_text_method, count: 1
      assert_select 'select option', text: internship_weeks[2].human_select_text_method, count: 1
      assert_select 'select option', text: internship_weeks[3].human_select_text_method, count: 0
    end

    test 'GET #show as a student only displays weeks that are not blocked' do
      max_candidates = 2
      internship_weeks = [Week.find_by(number: 1, year: 2020),
                          Week.find_by(number: 2, year: 2020)]
      school = create(:school, weeks: internship_weeks)
      blocked_internship_week = build(:internship_offer_week, blocked_applications_count: max_candidates,
                                                              week: internship_weeks[0])
      available_internship_week = build(:internship_offer_week, blocked_applications_count: 0,
                                                                week: internship_weeks[1])
      internship_offer = create(:internship_offer, max_candidates: max_candidates,
                                                   internship_offer_weeks: [blocked_internship_week,
                                                                            available_internship_week])
      sign_in(create(:student, school: school))
      get internship_offer_path(internship_offer)

      assert_select 'select option', text: blocked_internship_week.week.human_select_text_method, count: 0
      assert_select 'select option', text: available_internship_week.week.human_select_text_method, count: 1
    end

    test 'GET #show as student with existing draft application shows the draft' do
      weeks = [Week.find_by(number: 1, year: 2020), Week.find_by(number: 2, year: 2020)]
      internship_offer = create(:internship_offer, weeks: weeks)
      student = create(:student, school: create(:school, weeks: weeks))
      internship_application = create(:internship_application, :drafted, motivation: 'au taquet',
                                                                         student: student,
                                                                         internship_offer: internship_offer,
                                                                         week: weeks.last)
      sign_in(student)
      get internship_offer_path(internship_offer)
      assert_response :success
      assert_select "option[value=#{internship_offer.internship_offer_weeks.first.id}]"
      assert_select "option[value=#{internship_offer.internship_offer_weeks.last.id}][selected]"
    end

    test 'GET #show as student with existing submitted, approved, rejected application shows _state component' do
      weeks = [Week.find_by(number: 1, year: 2020), Week.find_by(number: 2, year: 2020)]
      internship_offer = create(:internship_offer, weeks: weeks)
      student = create(:student, school: create(:school, weeks: weeks))
      internship_applications = {
        submitted: create(:internship_application, :submitted, student: student),
        approved: create(:internship_application, :approved, student: student),
        rejected: create(:internship_application, :rejected, student: student),
        convention_signed: create(:internship_application, :convention_signed, student: student)
      }
      sign_in(student)
      internship_applications.each do |aasm_state, internship_application|
        get internship_offer_path(internship_application.internship_offer)
        assert_response :success
        assert_template "dashboard/students/internship_applications/states/_#{aasm_state}"
      end
    end

    test 'GET #show displays proper weeks' do
      internship_offer = create(:internship_offer, weeks: [Week.find_by(number: 8, year: 2019), Week.find_by(number: 9, year: 2019), Week.find_by(number: 21, year: 2019), Week.find_by(number: 22, year: 2019)])

      school = create(:school, weeks: [Week.find_by(number: 8, year: 2019), Week.find_by(number: 21, year: 2019)])
      sign_in(create(:student, school: school))
      travel_to(Date.new(2019, 5, 15)) do
        get internship_offer_path(internship_offer)

        assert_response :success
        assert_select 'option', text: 'Semaine du 20 mai au 26 mai'
      end
    end

    test 'GET #show with API offer' do
      weeks = [Week.find_by(number: 1, year: 2020), Week.find_by(number: 2, year: 2020)]
      internship_offer = create(:api_internship_offer, weeks: weeks)
      student = create(:student, school: create(:school, weeks: weeks))
      sign_in(student)
      get internship_offer_path(internship_offer)
      assert_response :success

    end

    test 'GET #show should be 404 if offer is discarded' do
      internship_offer = create(:internship_offer)
      student = create(:student, school: create(:school))
      sign_in(student)

      internship_offer.discard

      assert_raise ActionController::RoutingError do
         get internship_offer_path(internship_offer)
      end
    end
  end
end
