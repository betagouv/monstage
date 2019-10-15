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
      assert_select 'a.test-employer-website[href=?]', internship_offer.employer_website
    end

    test 'GET #show does not show website url when absent' do
      internship_offer = create(:internship_offer, employer_website: nil)
      get internship_offer_path(internship_offer)

      assert_response :success
      assert_select 'a.test-employer-website', 0
    end

    test 'GET #show not logged increments view_count' do
      internship_offer = create(:internship_offer)

      assert_no_changes -> { internship_offer.reload.view_count } do
        get internship_offer_path(internship_offer)
      end
    end

    test 'GET #show not logged as employer does not increment view_count' do
      internship_offer = create(:internship_offer)
      sign_in(internship_offer.employer)
      assert_no_changes -> { internship_offer.reload.view_count } do
        get internship_offer_path(internship_offer)
      end
    end

    test 'GET #show not logged as student does not increment view_count' do
      internship_offer = create(:internship_offer)
      sign_in(create(:student))
      assert_changes -> { internship_offer.reload.view_count },
                     from: 0,
                     to: 1 do
        get internship_offer_path(internship_offer)
      end
    end

    #
    # internship_applications checks
    #
    test 'GET #show as a visitor shows sign up form' do
      internship_offer = create(:internship_offer, weeks: weeks)

      get internship_offer_path(internship_offer)
      assert_template 'internship_applications/_visitor_form'
    end

    test 'GET #show displays application form for student' do
      student = create(:student)
      sign_in(student)
      get internship_offer_path(create(:internship_offer))

      assert_response :success
      assert_select 'form[id=?]', 'new_internship_application'
      assert_select "input[type=hidden][name='internship_application[user_id]'][value=#{student.id}]"
    end

    test 'GET #show displays application form for school_manager when internship_offer is reserved to school' do
      school = create(:school, :with_school_manager)
      class_room = create(:class_room, school: school)
      student = create(:student, class_room: class_room, school: school)

      sign_in(school.school_manager)
      internship_offer = create(:internship_offer, school: school)
      get internship_offer_path(internship_offer)

      assert_response :success
      assert_select '.alert.alert-info', text: "Ce stage est reservé au #{internship_offer.school}, afin de candidater prenez contact avec votre chef d'etablissement",
                                         count: 0
      assert_template 'internship_applications/_school_manager_form'
      assert_select 'form[id=?]', 'new_internship_application'
      assert_select "input[id=internship_application_student_ids_#{student.id}][type=checkbox]"
      assert_select 'span.h1-label', text: "Inscrire des élèves"
      assert_select '.btn-warning', text: "Inscrire des élèves"
      assert_select 'textarea[id=internship_application_motivation]', count: 0
      assert_select 'strong.tutor_name', text: internship_offer.tutor_name
      assert_select 'span.tutor_phone', text: internship_offer.tutor_phone
      assert_select "a.tutor_email[href=\"mailto:#{internship_offer.tutor_email}\"]", text: internship_offer.tutor_email
    end

    test 'GET #show does not display application form for school_manager when internship_offer is not reserved to school' do
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

    test 'GET #show as a student who can apply shows an enabled button with candidate label' do
      weeks = [Week.find_by(number: 1, year: 2020)]
      internship_offer = create(:internship_offer, weeks: weeks)
      sign_in(create(:student, school: create(:school, weeks: weeks)))

      get internship_offer_path(internship_offer)
      assert_template 'internship_applications/_student_form'
      assert_select '#new_internship_application', 1
      assert_select 'option', text: weeks.first.human_select_text_method, count: 1
      assert_select 'a[href=?]', '#internship-application-form', count: 1
      assert_select 'span.h1-label', text: "Je candidate"
      assert_select '.btn-warning', text: "Je candidate"
      assert_select 'textarea[id=internship_application_motivation]', count: 1
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
      assert_select 'a[href=?]', internship_offer.permalink
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

    test 'GET #show offers show next/previous navigation in list' do
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

    test 'GET #show offers show next and not previous when no previous' do
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

    test 'GET #show offers show previous and not next when no not' do
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

    test 'GET #show with forwards sector_id in params to next/prev ' do
      sector = create(:sector)
      previous_in_page = create(:internship_offer, sector: sector)
      current = create(:internship_offer, sector: sector)
      next_in_page = create(:internship_offer, sector: sector)
      student = create(:student, school: create(:school))

      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          sign_in(student)
          get internship_offer_path(id: current.id, sector_id: current.sector_id)

          assert_response :success
          assert_select 'a[href=?]',
                        internship_offer_path(id: previous_in_page.id,
                                              sector_id: current.sector_id)
          assert_select 'a[href=?]',
                        internship_offer_path(id: next_in_page.id,
                                              sector_id: current.sector_id)
        end
      end

    end

    test 'GET #show with forwards latitude/longitude in params to next/prev ' do
      previous_in_page = create(:internship_offer, title: "previous")
      current = create(:internship_offer, title: "current")
      next_in_page = create(:internship_offer, title: "next")
      student = create(:student, school: create(:school))

      InternshipOffer.stub :nearby, InternshipOffer.all do
        InternshipOffer.stub :by_weeks, InternshipOffer.all do
          sign_in(student)
          get internship_offer_path(id: current, latitude: 1, longitude: 2)

          assert_response :success
          assert_select 'a[href=?]',
                        internship_offer_path(id: previous_in_page.id,
                                              latitude: 1,
                                              longitude: 2)
          assert_select 'a[href=?]',
                        internship_offer_path(id: next_in_page.id,
                                              latitude: 1,
                                              longitude: 2)
        end
      end

    end
  end
end
