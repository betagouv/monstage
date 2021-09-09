# frozen_string_literal: true

require 'application_system_test_case'

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

  test 'student can not submit application wheen school have not choosen week' do
    school = create(:school, weeks: [])
    student = create(:student, school: school, class_room: create(:class_room, :troisieme_generale, school: school))
    internship_offer = create(:weekly_internship_offer, weeks: weeks)

    sign_in(student)
    visit internship_offer_path(internship_offer)
    # check application form opener and check form is hidden by default
    page.find '#internship-application-closeform', visible: false
    page.find('.test-missing-school-weeks', visible: false)

    click_on 'Je postule'

    # check application is now here, ensure feature is here
    page.find '#internship-application-closeform', visible: true
    page.find('.test-missing-school-weeks', visible: true)

    # check for phone and email fields disabled
    disabled_input_selectors = %w[
      internship_application[student_attributes][phone]
      internship_application[student_attributes][email]
    ].map do |disabled_selector|
      page.find "input[name='#{disabled_selector}'][disabled]", visible: true
    end
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

    prismic_root_path_stubbing do
      visit '/'
      click_on 'Candidatures'
      internship_applications.each do |_aasm_state, internship_application|
        click_on internship_application.internship_offer.title
        click_on 'Candidatures'
      end
    end
  end

  test 'student in troisieme_generale can draft, submit, and cancel(by_student) internship_applications' do
    weeks = [Week.find_by(number: 1, year: 2020)]
    school = create(:school, weeks: weeks)
    student = create(:student, school: school, class_room: create(:class_room, :troisieme_generale, school: school))
    internship_offer = create(:weekly_internship_offer, weeks: weeks)

    travel_to(weeks.first.week_date) do
      sign_in(student)
      visit internship_offer_path(internship_offer)

      # show application form
      page.find '#internship-application-closeform', visible: false
      click_on 'Je postule'
      page.find '#internship-application-closeform', visible: true

      # fill in application form
      select weeks.first.human_select_text_method, from: 'internship_application_internship_offer_week_id'
      find('#internship_application_motivation', visible: false).set('Je suis au taquet')
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

  test 'student in bac pro can draft, submit, and cancel(by_student) internship_applications' do
    school = create(:school)
    student = create(:student, school: school, class_room: create(:class_room, :bac_pro, school: school))
    internship_offer = create(:free_date_internship_offer)
    sign_in(student)
    visit internship_offer_path(internship_offer)

    # show application form
    page.find '#internship-application-closeform', visible: false
    click_on 'Je postule'
    page.find '#internship-application-closeform', visible: true

    # fill in application form
    find('#internship_application_motivation', visible: false).set('Je suis au taquet')
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

  test 'student in troisieme_segpa can draft, submit, and cancel(by_student) internship_applications' do
    school = create(:school)
    student = create(:student, school: school, class_room: create(:class_room, :troisieme_segpa, school: school))
    internship_offer = create(:troisieme_segpa_internship_offer)
    sign_in(student)
    visit internship_offer_path(internship_offer)

    # show application form
    page.find '#internship-application-closeform', visible: false
    click_on 'Je postule'
    page.find '#internship-application-closeform', visible: true

    # fill in application form
    find('#internship_application_motivation', visible: false).set('Je suis au taquet')
    refute page.has_selector?('.nav-link-icon-with-label-success') # green element on screen
    assert_changes lambda {
                     student.internship_applications
                            .where(aasm_state: :drafted)
                            .count
                   },
                   from: 0,
                   to: 1 do
      click_on 'Valider'
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
    page.find '#internship-application-closeform', visible: false
    click_on 'Je postule'
    page.find '#internship-application-closeform', visible: true

    # fill in application form
    find('#internship_application_motivation', visible: false).set('Je suis au taquet')
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
