# frozen_string_literal: true

require 'test_helper'

module Dashboard::InternshipAgreements
  class NewTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #new as School Manager' do
      operator = create(:user_operator)
      school = create(:school, :with_school_manager)
      internship_offer = create(:weekly_internship_offer, employer: operator,
        is_public: true,
        max_candidates: 1)
      internship_application = create(:weekly_internship_application, :approved, internship_offer: internship_offer)
      class_room = create(:class_room, school: school)
      internship_application.student.update(class_room_id: class_room.id, school_id: school.id)
      sign_in(school.school_manager)

      get new_dashboard_internship_agreement_path(internship_application_id: internship_application.id)

      assert_select 'h1', "Votre convention de stage"
      assert_select "input[value=\"#{school.name} à #{school.city} (Code UAI: #{school.code_uai})\"]", count: 1
      assert_select "input[value=\"#{school.school_manager.name}\"]", count: 1
      assert_select "input[value=\"#{internship_application.student.name}\"]", count: 1
      assert_select "input[value=\"#{class_room.name}\"]", count: 1
    end
  end
end
