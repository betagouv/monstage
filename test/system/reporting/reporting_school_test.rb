# frozen_string_literal: true

require 'application_system_test_case'
class ReportingSchoolTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @statistician = create(:statistician)
    @department_name = @statistician.department_name # Oise
    @school_with_segpa = create(
      :school_with_troisieme_segpa_class_room,
      zipcode: 60000 #Oise
    )
  end

  test 'School reporting can be filtered by school_track' do
    sign_in(@statistician)
    visit reporting_schools_path(department: @department_name)
    select '3e générale'
    page.assert_selector('td.align-middle.bl-1.bc-light > strong', count: 0)
    select '3e SEGPA'
    page.assert_selector('td.align-middle.bl-1.bc-light > strong', count: 1)
  end
end