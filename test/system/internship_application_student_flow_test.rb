require "application_system_test_case"

class InternshipOffersCreateTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers
  driven_by :selenium, using: :chrome

  test 'student can draft, submit internship_applications' do
    weeks = [Week.find_by(number:1, year: 2020)]
    student = create(:student, school: create(:school, weeks: weeks))
    internship_offer = create(:internship_offer, weeks: weeks)
    sign_in(student)
    visit '/'
    click_on 'Rechercher'
    click_on internship_offer.title

    page.find "#internship-application-closeform", visible: false
    click_on 'Je candidate'
    page.find "#internship-application-closeform", visible: true

    page.find("option[value='#{internship_offer.internship_offer_weeks.first.id}']").select_option
    fill_in 'internship_application_motivation', with: 'Je suis au taquet'


    assert_changes -> { student.reload.internship_applications.count },
                  from: 0,
                  to: 1 do
      click_on 'Valider'
    end
    assert_changes -> { student.reload
                               .internship_applications
                               .where(aasm_state: :submitted)
                               .count },
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
    internship_applications.each do |aasm_state, internship_application|
      click_on internship_application.internship_offer.title
      click_on 'Retour'
    end
  end
end
