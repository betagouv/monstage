# frozen_string_literal: true

require 'application_system_test_case'

class InternshipApplicationStudentFlowTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'student can draft, submit, and cancel(by_student) internship_applications' do
    weeks = [Week.find_by(number: 1, year: 2020)]
    student = create(:student, school: create(:school, weeks: weeks))
    internship_offer = create(:internship_offer, weeks: weeks)

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

      assert_changes lambda {
                       student.internship_applications
                              .where(aasm_state: :drafted)
                              .count
                     },
                     from: 0,
                     to: 1 do
        click_on 'Valider'
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
      click_on 'Candidature envoyée le'
      click_on 'Afficher ma candidature'
      click_on 'Annuler'
      click_on 'Confirmer'
      assert page.has_content?('Candidature annulée')
      assert_equal 1, student.internship_applications
                             .where(aasm_state: :canceled_by_student)
                             .count
    end
  end

  test 'student without school weeks can not submit application' do
    weeks = [Week.find_by(number: 1, year: 2020)]
    student = create(:student, school: create(:school, weeks: []))
    internship_offer = create(:internship_offer, weeks: weeks)

    travel_to(weeks.first.week_date) do
      sign_in(student)
      visit internship_offer_path(internship_offer)

      # check application form opener and check form is hidden by default
      page.find '#internship-application-closeform', visible: false
      page.find('.test-missing-school-weeks', visible: false)

      click_on 'Je postule'

      # check application is now here, ensure feature is here
      page.find '#internship-application-closeform', visible: true
      page.find('.test-missing-school-weeks', visible: true)
      # page.find("a[href=?]", account_path(user: {missing_school_weeks_id: student.school_id}))
      assert_changes lambda  { student.reload.missing_school_weeks_id },
                     from: nil,
                     to: student.school.id do
        click_on 'Je souhaite une semaine de stage'
      end
    end
  end

  test 'student can browse his internship_applications' do
    student = create(:student)
    internship_applications = {
      drafted: create(:internship_application, :drafted, student: student),
      submitted: create(:internship_application, :submitted, student: student),
      approved: create(:internship_application, :approved, student: student),
      rejected: create(:internship_application, :rejected, student: student),
      convention_signed: create(:internship_application, :convention_signed, student: student),
      canceled_by_student: create(:internship_application, :canceled_by_student, student: student)
    }
    sign_in(student)
    visit '/'
    click_on 'Candidatures'
    internship_applications.each do |_aasm_state, internship_application|
      click_on internship_application.internship_offer.title
      click_on 'Candidatures'
    end
  end
end
