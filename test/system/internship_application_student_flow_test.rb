# frozen_string_literal: true

require 'application_system_test_case'
include ActiveJob::TestHelper
class InternshipApplicationStudentFlowTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ThirdPartyTestHelpers

  test 'student not in class room can not ask for week' do
    school = create(:school, weeks: [])
    student = create(:student, school: school, class_room: create(:class_room, :troisieme_generale, school: school))
    internship_offer = create(:weekly_internship_offer, weeks: weeks)

    sign_in(student)
    visit internship_offer_path(internship_offer)
    page.find 'a', text: 'Mon profil'
    assert_select 'a', text: 'Je postule', count: 0
  end

  test 'student can submit application wheen school has not choosen any week yet' do
    school = create(:school, weeks: [])
    student = create(:student, school: school, class_room: create(:class_room, :troisieme_generale, school: school))
    internship_offer = create(:weekly_internship_offer, weeks: weeks)

    sign_in(student)
    visit new_internship_offer_internship_application_path(internship_offer_id: internship_offer.id)
    page.find('.test-missing-school-weeks', visible: true)

    click_on 'Valider'
  end

  test 'student with no class_room can submit a 3e prepa métier application when school have not choosen week' do
    weeks = Week.selectable_from_now_until_end_of_school_year.to_a.first(2)
    school = create(:school, weeks: [])
    student = create(:student, school: school)
    internship_offer = create(:weekly_internship_offer, weeks: weeks)

    sign_in(student)
    visit internship_offer_path(internship_offer)
    first(:link, 'Postuler').click

    # check application is now here, ensure feature is here
    
    page.find('.test-missing-school-weeks', visible: true)
    week_label = Week.selectable_from_now_until_end_of_school_year
                     .first
                     .human_select_text_method

    select(week_label)
    # check for phone fields disabled
    page.find "input[name='internship_application[student_attributes][phone]'][disabled]", visible: true
    # check for email fields
    page.find "input[name='internship_application[student_attributes][email]']", visible: true
    page.find("input[type='submit'][value='Valider']").click

    page.find('h1', text: 'Votre candidature')
    page.find("input[type='submit'][value='Envoyer']").click
  end

  test 'student with no class_room can submit a 3e segpa when school have not choosen week' do
    # weeks = Week.selectable_from_now_until_end_of_school_year.to_a.first(2)
    # school = create(:school, weeks: [])
    # student = create(:student, school: school)
    # internship_offer = create(:troisieme_segpa_internship_offer)

    # sign_in(student)
    # visit internship_offer_path(internship_offer)
    # # check application form opener and check form is hidden by default
    # page.find '#internship-application-closeform', visible: false

    # click_on 'Je postule'
    # # check application is now here, ensure feature is here
    # # page.find '#internship-application-closeform', visible: true
    # # check for phone and email fields disabled
    # page.find("input[type='submit'][value='Valider']").click
    # assert page.has_selector?("a[href='/internship_offers/#{internship_offer.id}']", count: 1)
    # page.find("input[type='submit'][value='Valider']").click
    # page.find('h1', text: 'Mes candidatures')
    # assert page.has_content?(internship_offer.title)
  end

  test 'student with no class_room can submit a 3e generale application when school have not choosen week' do
    # weeks = Week.selectable_from_now_until_end_of_school_year.to_a.first(2)
    # school = create(:school, weeks: [])
    # student = create(:student, school: school)
    # internship_offer = create(:troisieme_segpa_internship_offer)

    # sign_in(student)
    # visit internship_offer_path(internship_offer)
    # # check application form opener and check form is hidden by default
    # page.find '#internship-application-closeform', visible: false

    # click_on 'Je postule'
    # # check application is now here, ensure feature is here
    # page.find '#internship-application-closeform', visible: true
    # # check for phone fields disabled
    # page.find "input[name='internship_application[student_attributes][phone]'][disabled]", visible: true
    # # check for email fields
    # page.find "input[name='internship_application[student_attributes][email]']", visible: true
    # page.find("input[type='submit'][value='Valider']").click
    # assert page.has_selector?("a[href='/internship_offers/#{internship_offer.id}']", count: 1)
    # page.find("input[type='submit'][value='Envoyer']").click
    # page.find('h1', text: 'Mes candidatures')
    # assert page.has_content?(internship_offer.title)
  end

  test 'student can browse his internship_applications' do
    school = create(:school)
    student = create(:student, school: school, class_room: create(:class_room, :troisieme_generale, school: school))
    internship_applications = {
      drafted: create(:weekly_internship_application, :drafted, student: student),
      submitted: create(:weekly_internship_application, :submitted, student: student),
      approved: create(:weekly_internship_application, :approved, student: student),
      rejected: create(:weekly_internship_application, :rejected, student: student),
      convention_signed: create(:weekly_internship_application, :convention_signed, student: student),
      canceled_by_student: create(:weekly_internship_application, :canceled_by_student, student: student)
    }
    sign_in(student)
    visit '/'
    click_on 'Candidatures'
    internship_applications.each do |_aasm_state, internship_application|
      click_on internship_application.internship_offer.title
      click_on 'Candidatures'
    end
  end

  test 'GET #show as Student with existing draft application shows the draft' do
    if ENV.fetch('RUN_BRITTLE_TEST', true)
      # weeks = [Week.find_by(number: 1, year: 2020), Week.find_by(number: 2, year: 2020)]
      # internship_offer      = create(:weekly_internship_offer, weeks: weeks)
      # school                = create(:school, weeks: weeks)
      # student               = create(:student, school: school, class_room: create(:class_room, :troisieme_generale, school: school))
      # internship_application = create(:weekly_internship_application,
      #                                 :drafted,
      #                                 motivation: 'au taquet',
      #                                 student: student,
      #                                 internship_offer: internship_offer,
      #                                 week: weeks.last)

      # travel_to(weeks[0].week_date - 1.week) do
      #   sign_in(student)
      #   visit internship_offer_path(internship_offer)
      #   within('select[name="internship_application[week_id]"]') do
      #     assert page.find(:xpath, 'option[1]').selected?
      #     refute page.find(:xpath, 'option[2]').selected?
      #     assert_equal internship_offer.internship_offer_weeks.second.week.id.to_s, page.find(:xpath, 'option[1]').value
      #     assert_equal internship_offer.internship_offer_weeks.first.week.id.to_s, page.find(:xpath, 'option[2]').value
      #   end
      # end
    end
  end

  test 'student can receive a SMS when employer accepts her application' do
    school = create(:school)
    student = create(:student,
                     school: school,
                     class_room: create(:class_room, :troisieme_generale, school: school),
                     email: "",
                     phone: '+330612345678'
    )
    internship_application = create(
      :weekly_internship_application,
      :submitted,
      student: student
    )
    sign_in(internship_application.internship_offer.employer)
    bitly_stub do
      visit dashboard_internship_offer_internship_applications_path(internship_application.internship_offer)
      click_on 'Accepter'
      click_on 'Confirmer'
    end
  end

  test 'student with approved application can see employer\'s address' do
    school = create(:school)
    student = create(:student,
                     school: school,
                     class_room: create(
                       :class_room,
                       :troisieme_generale,
                       school: school
                     )
    )
    internship_application = create(
      :weekly_internship_application,
      :approved,
      student: student
    )
    sign_in(student)
    visit '/'
    visit dashboard_students_internship_applications_path(student, internship_application.internship_offer)
    click_link(internship_application.internship_offer.title)
    assert page.has_selector?("a[href='#tab-convention-detail']", count: 1)
  end

  test 'student with submittted application can not see employer\'s address' do
    school = create(:school)
    student = create(:student,
                     school: school,
                     class_room: create(:class_room, :troisieme_generale, school: school)
    )
    internship_application = create(
      :weekly_internship_application,
      :submitted,
      student: student
    )
    sign_in(student)
    # visit '/'
    visit dashboard_students_internship_applications_path(student, internship_application.internship_offer)
    click_link(internship_application.internship_offer.title)
    refute page.has_selector?("a[href='#tab-convention-detail']", count: 1)
  end

  test 'student in troisieme_generale can draft, submit, and cancel(by_student) internship_applications' do
    weeks = [Week.find_by(number: 1, year: 2020)]
    school = create(:school, weeks: weeks)
    student = create(:student,
                     school: school,
                     class_room: create( :class_room,
                                         :troisieme_generale,
                                         school: school)
                    )
    internship_offer = create(:weekly_internship_offer, weeks: weeks)

    travel_to(weeks.first.week_date) do
      sign_in(student)
      visit internship_offer_path(internship_offer)

      # show application form
      first(:link, 'Postuler').click

      # fill in application form
      select weeks.first.human_select_text_method, from: 'internship_application_week_id'
      find('#internship_application_motivation').native.send_keys('Je suis au taquet')
      refute page.has_selector?('.nav-link-icon-with-label-success') # green element on screen
      assert_changes lambda {
                       student.internship_applications
                              .where(aasm_state: :drafted)
                              .count
                     },
                     from: 0,
                     to: 1 do
        click_on 'Valider'
        page.find('#submit_application_form') # timer
      end

      assert_changes lambda {
                       student.internship_applications
                              .where(aasm_state: :submitted)
                              .count
                     },
                     from: 0,
                     to: 1 do
        click_on 'Envoyer'
      end

      assert page.has_content?('Candidature envoyée')
      click_on 'Candidature envoyée le'
      assert page.has_selector?('.nav-link-icon-with-label-success', count: 2)
      click_on 'Afficher ma candidature'
      click_on 'Annuler'
      click_on 'Confirmer'
      assert page.has_content?('Candidature annulée')
      assert page.has_selector?('.nav-link-icon-with-label-success', count: 1)
      assert_equal 1, student.internship_applications
                             .where(aasm_state: :canceled_by_student)
                             .count
    end
  end

  test 'student in troisieme_segpa can draft, submit, and cancel(by_student) internship_applications' do
    school = create(:school)
    student = create(:student, school: school, class_room: create(:class_room, :troisieme_segpa, school: school))
    internship_offer = create(:troisieme_segpa_internship_offer)
    sign_in(student)
    visit internship_offer_path(internship_offer)

    # show application form
    first(:link, 'Postuler').click

    # fill in application form
    find('#internship_application_motivation').native.send_keys('Je suis au taquet')

    assert_changes lambda {
                     student.internship_applications
                            .where(aasm_state: :drafted)
                            .count
                   },
                   from: 0,
                   to: 1 do
      click_on 'Valider'
      student.reload
      page.find('#submit_application_form')
    end

    assert_changes lambda {
                     student.internship_applications
                            .where(aasm_state: :submitted)
                            .count
                   },
                   from: 0,
                   to: 1 do
      click_on 'Envoyer'
    end

    assert page.has_content?('Candidature envoyée')
    click_on 'Candidature envoyée le'
    assert page.has_selector?('.nav-link-icon-with-label-success', count: 2)
    click_on 'Afficher ma candidature'
    click_on 'Annuler'
    click_on 'Confirmer'
    assert page.has_content?('Candidature annulée')
    assert page.has_selector?('.nav-link-icon-with-label-success', count: 1)
    assert_equal 1, student.internship_applications
                           .where(aasm_state: :canceled_by_student)
                           .count
  end

  test 'student in troisieme_prepa_metiers can draft, submit, and cancel(by_student) internship_applications' do
    school = create(:school)
    student = create(:student, school: school, class_room: create(:class_room, :troisieme_prepa_metiers, school: school))
    internship_offer = create(:troisieme_prepa_metiers_internship_offer)
    sign_in(student)
    visit internship_offer_path(internship_offer)

    # show application form
    first(:link, 'Postuler').click

    # fill in application form
    find('#internship_application_motivation').native.send_keys('Je suis au taquet')
    refute page.has_selector?('.nav-link-icon-with-label-success') # green element on screen
    assert_changes lambda {
                     student.internship_applications
                            .where(aasm_state: :drafted)
                            .count
                   },
                   from: 0,
                   to: 1 do
      click_on 'Valider'
      page.find('#submit_application_form') # timer
    end

    assert_changes lambda {
                     student.internship_applications
                            .where(aasm_state: :submitted)
                            .count
                   },
                   from: 0,
                   to: 1 do
      click_on 'Envoyer'
    end

    assert page.has_content?('Candidature envoyée')
    click_on 'Candidature envoyée le'
    assert page.has_selector?('.nav-link-icon-with-label-success', count: 2)
    click_on 'Afficher ma candidature'
    click_on 'Annuler'
    click_on 'Confirmer'
    assert page.has_content?('Candidature annulée')
    assert page.has_selector?('.nav-link-icon-with-label-success', count: 1)
    assert_equal 1, student.internship_applications
                           .where(aasm_state: :canceled_by_student)
                           .count
  end
end
