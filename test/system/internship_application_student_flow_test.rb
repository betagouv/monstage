# frozen_string_literal: true

require 'application_system_test_case'

class InternshipOffersCreateTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'student can draft, submit internship_applications' do
    weeks = [Week.find_by(number: 1, year: 2020)]
    student = create(:student, school: create(:school, weeks: weeks))
    internship_offer = create(:internship_offer, weeks: weeks)
    sign_in(student)
    visit '/'
    click_on 'Recherche'
    click_on internship_offer.title

    # show application form
    page.find '#internship-application-closeform', visible: false
    click_on 'Je candidate'
    page.find '#internship-application-closeform', visible: true

    # fill in application form
    select weeks.first.human_select_text_method, from: 'internship_application_internship_offer_week_id'
    fill_in 'internship_application_motivation', with: 'Je suis au taquet'

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
  end

  test 'student can browse his internship_applications' do
    student = create(:student)
    internship_applications = {
      drafted: create(:internship_application, :drafted, student: student),
      submitted: create(:internship_application, :submitted, student: student),
      approved: create(:internship_application, :approved, student: student),
      rejected: create(:internship_application, :rejected, student: student),
      convention_signed: create(:internship_application, :convention_signed, student: student)
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
