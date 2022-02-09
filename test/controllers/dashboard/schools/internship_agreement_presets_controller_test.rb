# frozen_string_literal: true

require 'test_helper'

module Dashboard
  module Schools
    class StudentsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      #
      # update by group
      #
      test 'PATCH as SchoolManager update preset' do
        school = create(:school, :with_school_manager)
        sign_in(school.school_manager)
        date = 2.years.ago.to_date

        patch dashboard_school_internship_agreement_preset_path(school_id: school, id: school.internship_agreement_preset),
              params: {
                internship_agreement_preset: {
                  school_delegation_to_sign_delivered_at: date
                }
             }
        assert_redirected_to dashboard_internship_agreements_path
        school.internship_agreement_preset.reload
        assert_equal date, school.internship_agreement_preset.school_delegation_to_sign_delivered_at
      end

      #
      # update by group
      #
      test 'GET edit as SchoolManager access full form' do
        school = create(:school, :with_school_manager, :with_agreement_presets)
        sign_in(school.school_manager)

        get edit_dashboard_school_internship_agreement_preset_path(school_id: school, id: school.internship_agreement_preset)
        assert_response :success
      end
    end
  end
end
