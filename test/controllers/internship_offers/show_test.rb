# frozen_string_literal: true

require 'test_helper'

module InternshipOffers
  class ShowTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    #
    # School Manager
    #
    test 'GET #show as SchoolManager does not display application when internship_offer is not reserved to school' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, class_room: class_room, school: school)
      main_teacher = create(:main_teacher, class_room: class_room, school: school)

      sign_in(main_teacher)
      internship_offer = create(:internship_offer)
      get internship_offer_path(internship_offer)

      assert_response :success
      assert_select 'form[id=?]', 'new_internship_application', count: 0
      assert_select 'strong.tutor_name', text: internship_offer.tutor_name
      assert_select 'span.tutor_phone', text: internship_offer.tutor_phone
      assert_select "a.tutor_email[href=\"mailto:#{internship_offer.tutor_email}\"]",
                    text: internship_offer.tutor_email
    end

    #
    # Student
    #
    test 'GET #show as Student does increments view_count' do
      internship_offer = create(:internship_offer)
      sign_in(create(:student))
      assert_changes -> { internship_offer.reload.view_count },
                     from: 0,
                     to: 1 do
        get internship_offer_path(internship_offer)
      end
    end

    test 'GET #show as Student displays application form' do
      student = create(:student)
      sign_in(student)
      get internship_offer_path(create(:internship_offer))

      assert_response :success
      assert_select 'form[id=?]', 'new_internship_application'
      assert_select "input[type=hidden][name='internship_application[user_id]'][value=#{student.id}]"
    end

    test 'GET #show as Student when school has no weeks' do
      school = create(:school, weeks: [])
      student = create(:student, school: school)
      sign_in(student)
      get internship_offer_path(create(:internship_offer))

      assert_response :success
      assert_select 'form[id=?]', 'new_internship_application', count: 1
      disabled_input_selectors = %w[
        internship_application[student_attributes][phone]
        internship_application[student_attributes][email]
      ].map do |disabled_selector|
        assert_select("[name='#{disabled_selector}'][disabled=disabled]",
                      { count: 1 },
                      "missing disabled input : #{disabled_selector}")
      end

      assert_select(".student-form-missing-school-weeks",
                    { count: 1 },
                    "missing rendering of call_to_action/student_missing_school_weeks")
      assert_select("a[href=?]",
                    account_path(user: { missing_school_weeks_id: student.school.id }))
      student.update(missing_school_weeks_id: school.id)
      get internship_offer_path(create(:internship_offer))

      assert_response :success
      assert_select(".student-form-missing-school-weeks",
                    { count: 0 },
                    "missing rendering of call_to_action/student_missing_school_weeks")
    end

    test 'GET #show as Student who can apply shows an enabled button with candidate label' do
      weeks = [Week.find_by(number: 1, year: 2020)]
      internship_offer = create(:internship_offer, weeks: weeks)

      travel_to(weeks[0].week_date) do
        sign_in(create(:student, school: create(:school, weeks: weeks)))
        get internship_offer_path(internship_offer)
        assert_template 'internship_applications/call_to_action/_student'
        assert_select '#new_internship_application', 1
        assert_select 'option', text: weeks.first.human_select_text_method, count: 1
        assert_select 'a[href=?]', '#internship-application-form', count: 1
        assert_select '.btn-danger', text: "Je candidate"
      end
    end

    test 'GET #show as Student a message when he cannot apply to a reserved internship offer' do
      weeks = [Week.find_by(number: 1, year: 2020)]
      student = create(:student, school: create(:school, weeks: weeks))
      other_school = create(:school)
      internship_offer = create(:internship_offer, school: other_school, weeks: weeks)
      sign_in(student)
      get internship_offer_path(internship_offer)

      assert_select '.badge-school-reserved', text: "Stage reservé (aux élèves du collège #{internship_offer.school})",
                                         count: 1
      assert_select '#new_internship_application', 0
    end

    test 'GET #show as Student who can apply to a reserved internship offer' do
      weeks = [Week.find_by(number: 1, year: 2020)]
      student = create(:student, school: create(:school, weeks: weeks))
      internship_offer = create(:internship_offer, school: student.school, weeks: weeks)
      sign_in(student)
      get internship_offer_path(internship_offer)

      assert_template 'internship_applications/call_to_action/_student'
      assert_select '#new_internship_application', 1
    end

    test 'GET #show as Student only displays weeks that are not blocked' do
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
      travel_to(internship_weeks[0].week_date - 1.week) do
        sign_in(create(:student, school: school))
        get internship_offer_path(internship_offer)

        assert_select 'select option', text: blocked_internship_week.week.human_select_text_method, count: 0
        assert_select 'select option', text: available_internship_week.week.human_select_text_method, count: 1
      end
    end

    test 'GET #show as Student with existing draft application shows the draft' do
      weeks = [Week.find_by(number: 1, year: 2020), Week.find_by(number: 2, year: 2020)]
      internship_offer = create(:internship_offer, weeks: weeks)
      student = create(:student, school: create(:school, weeks: weeks))
      internship_application = create(:internship_application, :drafted, motivation: 'au taquet',
                                                                         student: student,
                                                                         internship_offer: internship_offer,
                                                                         week: weeks.last)
      travel_to(weeks[0].week_date - 1.week) do
        sign_in(student)
        get internship_offer_path(internship_offer)
        assert_response :success
        assert_select "option[value=#{internship_offer.internship_offer_weeks.first.id}]"
        assert_select "option[value=#{internship_offer.internship_offer_weeks.last.id}][selected]"
      end
    end

    test 'GET #show as Student with existing submitted, approved, rejected application shows _state component' do
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

    test 'GET #show as Student displays weeks that matches school weeks' do
      week_not_matching = Week.find_by(number: 11, year: 2019)
      matching_week = Week.find_by(number: 12, year: 2019)

      internship_offer = create(:internship_offer,
                                weeks: [matching_week,
                                        week_not_matching])

      school = create(:school, weeks: [matching_week])
      sign_in(create(:student, school: school))
      travel_to(matching_week.week_date - 1.month) do
        get internship_offer_path(internship_offer)

        assert_response :success
        assert_select 'option', text: week_not_matching.human_select_text_method,
                                count: 0
        assert_select 'option', text: matching_week.human_select_text_method,
                                count: 1
      end
    end

    test 'GET #show as Student with API offer' do
      weeks = [Week.find_by(number: 1, year: 2020), Week.find_by(number: 2, year: 2020)]
      internship_offer = create(:api_internship_offer, weeks: weeks)
      student = create(:student, school: create(:school, weeks: weeks))
      sign_in(student)
      get internship_offer_path(internship_offer)
      assert_response :success
      assert_select 'a[href=?]', internship_offer.permalink
      assert_template 'internship_applications/call_to_action/_api'
    end

    test 'GET #show as Student redirects to his tailored list of internship_offers when offer is discarded' do
      internship_offer = create(:internship_offer)
      student = create(:student, school: create(:school))
      sign_in(student)

      internship_offer.discard

      get internship_offer_path(internship_offer)
      assert_redirected_to Presenters::User.new(student).default_internship_offers_path
    end

    test 'GET #show as Student shows next/previous navigation in list' do
      previous_out = create(:internship_offer, title: "previous_out")
      previous_in_page = create(:internship_offer, title: "previous")
      current = create(:internship_offer, title: "current")
      next_in_page = create(:internship_offer, title: "next")
      next_out = create(:internship_offer, title: "next_out")
      student = create(:student, school: create(:school))

      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          sign_in(student)
          get internship_offer_path(current)

          assert_response :success
          assert_select 'a[href=?]', internship_offer_path(previous_in_page)
          assert_select 'a[href=?]', internship_offer_path(next_in_page)
        end
      end
    end

    test 'GET #show as Student shows next and not previous when no previous' do
      current = create(:internship_offer, title: "current")
      next_in_page = create(:internship_offer, title: "next")
      next_out = create(:internship_offer, title: "next_out")
      student = create(:student, school: create(:school))

      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          sign_in(student)
          get internship_offer_path(current)

          assert_response :success
          assert_select 'a.list-item-previous', count: 0
          assert_select 'a[href=?]', internship_offer_path(next_in_page)
        end
      end
    end

    test 'GET #show as Student shows previous and not next when no not' do
      previous_out = create(:internship_offer, title: "previous_out")
      previous_in_page = create(:internship_offer, title: "previous")
      current = create(:internship_offer, title: "current")
      student = create(:student, school: create(:school))

      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          sign_in(student)
          get internship_offer_path(current)

          assert_response :success
          assert_select 'a[href=?]', internship_offer_path(previous_in_page)
          assert_select 'a.list-item-next', count: 0
        end
      end
    end

    test 'GET #show as Student with forwards latitude, longitude & radius in params to next/prev ' do
      previous_in_page = create(:internship_offer, title: "previous")
      current = create(:internship_offer, title: "current")
      next_in_page = create(:internship_offer, title: "next")
      student = create(:student, school: create(:school))

      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          sign_in(student)
          get internship_offer_path(id: current, radius: 1_000, latitude: 1, longitude: 2)

          assert_response :success
          assert_select 'a[href=?]',
                        internship_offer_path(id: previous_in_page.id,
                                              latitude: 1,
                                              longitude: 2,
                                              radius: 1_000)
          assert_select 'a[href=?]',
                        internship_offer_path(id: next_in_page.id,
                                              latitude: 1,
                                              longitude: 2,
                                              radius: 1_000)
        end
      end
    end

    test 'GET #show as Student when school.weeks is empty show alert form' do
      student = create(:student, school: create(:school))
      internship_offer = create(:internship_offer)
      student = create(:student, school: create(:school))
      sign_in(student)

      get internship_offer_path(internship_offer)
      assert_template 'internship_applications/call_to_action/_student'
      assert_template 'internship_applications/forms/_student'
    end

    #
    # Visitor
    #
    test 'GET #show as Visitor show breadcrumb with link to previous page' do
      internship_offer = create(:internship_offer)
      forwarded_params = { latitude: Coordinates.paris[:lat],
                           longitude: Coordinates.paris[:lon],
                           radius: 60_000,
                           city: 'Mantes-la-Jolie',
                           keyword: 'Boucher+ecarisseur',
                           page: 5,
                           filter: 'past' }

      get internship_offer_path({id: internship_offer.id}.merge(forwarded_params))
      assert_response :success
      assert_select "#test-backlink"
      assert_template 'internship_offers/_breadcrumb'
      assert_template 'internship_applications/call_to_action/_visitor'
      assert_template 'internship_applications/forms/_visitor'
      assert_select("a[href=?]",
                    internship_offers_path(forwarded_params))
    end

    test 'GET #show as Visitor when internship_offer is unpublished redirects to home' do
      internship_offer = create(:internship_offer)
      internship_offer.update!(published_at: nil)
      get internship_offer_path(internship_offer)
      assert_redirected_to internship_offers_path
    end

    test 'GET #show as Visitor shows sign up form' do
      internship_offer = create(:internship_offer, weeks: weeks)

      get internship_offer_path(internship_offer)
      assert_template 'internship_applications/call_to_action/_visitor'
    end

    test 'GET #show as Visitor does not increment view_count' do
      internship_offer = create(:internship_offer)

      assert_no_changes -> { internship_offer.reload.view_count } do
        get internship_offer_path(internship_offer)
      end
    end

    test 'GET #show website url when present' do
      internship_offer = create(:internship_offer, employer_website: 'http://google.com')
      get internship_offer_path(internship_offer)

      assert_response :success
      assert_select 'a.test-employer-website[href=?]', internship_offer.employer_website
    end

    test 'GET #show does not show website url when absent' do
      internship_offer = create(:internship_offer, employer_website: nil)
      get internship_offer_path(internship_offer)

      assert_response :success
      assert_select 'a.test-employer-website', 0
    end


    #
    # Employer
    #
    test 'GET #show as Employer does not increment view_count' do
      internship_offer = create(:internship_offer)
      sign_in(internship_offer.employer)
      assert_no_changes -> { internship_offer.reload.view_count } do
        get internship_offer_path(internship_offer)
      end
    end

    test 'GET #show as Employer when internship_offer is unpublished works' do
      internship_offer = create(:internship_offer)
      internship_offer.update!(published_at: nil)
      sign_in(internship_offer.employer)
      get internship_offer_path(internship_offer)
      assert_response :success
    end

    test 'GET #show as Employer displays internship_applications link' do
      published_at = 2.weeks.ago
      internship_offer = create(:internship_offer, published_at: published_at)
      sign_in(internship_offer.employer)
      get internship_offer_path(internship_offer)
      assert_response :success
      assert_template 'dashboard/internship_offers/_navigation'

      assert_select 'a[href=?]', edit_dashboard_internship_offer_path(internship_offer),
                    { count: 1 },
                    'missing edit internship_offer link for employer'

      assert_select 'a[href=?]', dashboard_internship_offer_internship_applications_path(internship_offer),
                    { text: '0 candidatures', count: 1},
                    'missing link to internship_applications for employer'

      assert_select 'a[href=?][data-method=delete]', dashboard_internship_offer_path(internship_offer),
                    { count: 1 },
                    'missing discard link for employer'

      assert_select 'span.internship_offer-published_at',
                    { text: "depuis le #{I18n.l(internship_offer.published_at, format: :human_mm_dd)}" },
                    'invalid published_at'

      assert_template "dashboard/internship_offers/_delete_internship_offer_modal",
                      "missing discard modal for employer"
    end

    test 'GET #show as employer before may or after september show duplicate/renew button' do
      internship_offer = create(:internship_offer)
      current_school_year = SchoolYear::Current.new

      sign_in(internship_offer.employer)

      travel_to(current_school_year.beginning_of_period - 1.month) do
        get internship_offer_path(internship_offer)
        assert_select ".test-duplicate-button", count: 0
        assert_select ".test-renew-button", count: 1
        assert_response :success
      end

      travel_to(current_school_year.beginning_of_period + 1.month) do
        get internship_offer_path(internship_offer)
        assert_select ".test-duplicate-button", count: 1
        assert_select ".test-renew-button", count: 0
        assert_response :success
      end

      travel_to(current_school_year.end_of_period - 1.month) do
        get internship_offer_path(internship_offer)
        assert_response :success
        assert_select ".test-duplicate-button", count: 1
        assert_select ".test-renew-button", count: 0
      end

      travel_to(current_school_year.end_of_period + 1.month) do
        get internship_offer_path(internship_offer)
        assert_response :success
        assert_select ".test-duplicate-button", count: 0
        assert_select ".test-renew-button", count: 1
      end
    end
  end
end
