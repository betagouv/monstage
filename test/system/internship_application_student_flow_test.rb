# frozen_string_literal: true

require 'application_system_test_case'
include ActiveJob::TestHelper
class InternshipApplicationStudentFlowTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  include ThirdPartyTestHelpers

  test 'student not in class room can not ask for week' do
    school = create(:school, weeks: [])
    student = create(:student, school: school, class_room: create(:class_room, school: school))
    internship_offer = create(:weekly_internship_offer, weeks: weeks)

    sign_in(student)
    visit internship_offer_path(internship_offer)
    page.find 'a', text: 'Mon profil'
    assert_select 'a', text: 'Je postule', count: 0
  end

  test 'student can submit application wheen school has not choosen any week yet' do
    school = create(:school, weeks: [])
    student = create(:student, school: school, class_room: create(:class_room, school: school))
    internship_offer = create(:weekly_internship_offer, weeks: weeks)

    sign_in(student)
    visit new_internship_offer_internship_application_path(internship_offer_id: internship_offer.id)
    page.find('.test-missing-school-weeks', visible: true)

    click_on 'Valider'
  end

  test 'student with no class_room can submit an application when school have not choosen week' do
    if ENV['RUN_BRITTLE_TEST']
      weeks = Week.selectable_from_now_until_end_of_school_year.to_a.first(2)
      school = create(:school, weeks: [])
      student = create(:student, school: school)
      internship_offer = create(:weekly_internship_offer, weeks: weeks)

      sign_in(student)
      visit internship_offer_path(internship_offer)
      first(:link, 'Postuler').click

      all('a', text: 'Postuler').first.click
      # check application is now here, ensure feature is here
      page.find '#internship-application-closeform', visible: true
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
      assert page.has_selector?(".fr-card__title a[href='/internship_offers/#{internship_offer.id}']", count: 1)
      click_button('Envoyer')
      page.find('h1', text: 'Félicitations !')
      page.find('h2.h1.display-1', text:'1')
      assert page.has_content?(internship_offer.title)
    end
  end

  test 'student with no class_room can submit an application when school has not choosen week' do
    # Pay attention when merging this very test: it's here to stay
    weeks = [Week.find_by(number: 1, year: 2020), Week.find_by(number: 2, year: 2020)]
    internship_offer = create(:weekly_internship_offer, weeks: weeks)
    school           = create(:school,:with_school_manager, weeks: [])
    student          = create(:student, school: school)
    assert_equal 1, internship_offer.remaining_seats_count
    travel_to(Date.new(2019, 9, 1)) do
      sign_in(student)
      visit internship_offer_path(internship_offer)

      all('a', text: 'Postuler').first.click
      # check for phone fields disabled
      page.find "input[name='internship_application[student_attributes][phone]'][disabled]", visible: true
      # check for email fields
      page.find "input[name='internship_application[student_attributes][email]']", visible: true
      select weeks.first.human_select_text_method, from: 'internship_application_week_id'
      page.find("input[type='submit'][value='Valider']").click
      assert page.has_selector?(".fr-card__title a[href='/internship_offers/#{internship_offer.id}']", count: 1)
      click_button('Envoyer')
      page.find('h1', text: 'Félicitations !')
    end
  end

  test 'student can browse his internship_applications' do
    school = create(:school, :with_school_manager)
    student = create(:student, school: school)
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
      url = dashboard_students_internship_application_path(
        student_id: student.id,
        id: internship_application.id
      )
      page.find "a[href='#{url}']",
                text: internship_application.internship_offer.title,
                wait: 4

      visit url
      all( 'a', text: 'Candidatures').first.click
    end
  end

  test 'GET #show as Student with existing draft application shows the draft' do
    if ENV['RUN_BRITTLE_TEST']
      weeks = [Week.find_by(number: 1, year: 2020), Week.find_by(number: 2, year: 2020)]
      internship_offer      = create(:weekly_internship_offer, weeks: weeks)
      school                = create(:school, weeks: weeks)
      student               = create(:student, school: school, class_room: create(:class_room, school: school))
      internship_application = create(:weekly_internship_application,
                                      :drafted,
                                      motivation: 'au taquet',
                                      student: student,
                                      internship_offer: internship_offer,
                                      week: weeks.last)

      travel_to(weeks[0].week_date - 1.week) do
        sign_in(student)
        visit internship_offer_path(internship_offer)
        find('.h1', text: internship_offer.title)
        find('.h3', text: internship_offer.employer_name)
        find('.h6', text: internship_offer.street)
        find('.h4', text: 'Informations sur le stage')
        find('.reboot-trix-content', text: internship_offer.description)
        assert page.has_content? 'Stage individuel'
      end

    end
  end

  test 'student can receive a SMS when employer accepts her application' do
    school = create(:school)
    student = create(:student,
                     school: school,
                     class_room: create(:class_room, school: school),
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
    school = create(:school, :with_school_manager)
    student = create(:student,
                     school: school,
                     class_room: create(:class_room, school: school)
    )
    internship_application = create(
      :weekly_internship_application,
      :approved,
      student: student
    )
    sign_in(student)
    visit '/'
    visit dashboard_students_internship_applications_path(student, internship_application.internship_offer)
    url= dashboard_students_internship_application_path(
      student_id: student.id,
      id: internship_application.id
    )
    assert page.has_selector?("a[href='#{url}']", count: 1)
    visit url
    assert page.has_selector?("a[href='#tab-convention-detail']", count: 1)
  end

  test 'student with submittted application can not see employer\'s address' do
    school = create(:school)
    student = create(:student,
                     school: school,
                     class_room: create(:class_room, school: school)
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

  test 'student can draft, submit, and cancel(by_student) internship_applications' do
    weeks = [Week.find_by(number: 1, year: 2020)]
    school = create(:school, weeks: weeks)
    student = create(:student,
                     school: school,
                     class_room: create( :class_room,
                                         school: school)
                    )
    internship_offer = create(:weekly_internship_offer, weeks: weeks)

    travel_to(weeks.first.week_date) do
      sign_in(student)
      visit internship_offer_path(internship_offer)

      # show application form
      first(:link, 'Postuler').click

      # fill in application form
      human_first_week_label = weeks.first.human_select_text_method
      select human_first_week_label, from: 'internship_application_week_id', wait: 3
      find('#internship_application_motivation', wait: 3).native.send_keys('Je suis au taquet')
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
        sleep 0.15
      end

      page.find('h1', text: 'Félicitations !')
    end
  end

  test 'when an employer tries to access application forms, he fails' do
    employer = create(:employer)
    internship_offer = create(:weekly_internship_offer)
    visit internship_offer_path(internship_offer.id)
    first(:link, 'Postuler').click
    fill_in("Adresse électronique", with: employer.email)
    fill_in("Mot de passe", with: employer.password)
    click_button('Connexion')

    assert page.has_selector?("span#alert-text", text: "Vous n'êtes pas autorisé à effectuer cette action.")
  end
end
