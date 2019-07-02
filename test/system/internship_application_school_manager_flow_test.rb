# frozen_string_literal: true

require 'application_system_test_case'

class InternshipApplicationSchoolManagerFlowTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'school_manager can submit internship_applications' do
    weeks = [Week.find_by(number: 1, year: 2020)]
    school = create(:school, :with_school_manager, weeks: weeks)
    class_room = create(:class_room, school: school)
    student_1 = create(:student, first_name: "Rick 1", class_room: class_room)
    student_2 = create(:student, first_name: "Rick 2", class_room: class_room)
    student_3 = create(:student, first_name: "Rick 3", class_room: class_room)
    internship_offer = create(:internship_offer, weeks: weeks, school: school)

    sign_in(school.school_manager)
    visit '/'
    click_on 'Recherche'
    page.find("[data-test-id=\"#{internship_offer.id}\"]").click
    # show application form
    page.find '#internship-application-closeform', visible: false
    click_on 'Inscrire des élèves'
    page.find '#internship-application-closeform', visible: true

    # fill in application form
    select weeks.first.human_select_text_method, from: 'internship_application_internship_offer_week_id'
    select student_1.name, from: 'internship_application_student_ids'
    select student_2.name, from: 'internship_application_student_ids'

    assert_changes lambda {
                     InternshipApplication.where(aasm_state: :approved)
                                          .count
                   },
                   from: 0,
                   to: 2 do
      click_on 'Valider'
    end

  end
end
