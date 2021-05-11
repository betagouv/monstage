require 'application_system_test_case'
class ReportingSchoolTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @statistician = create(:statistician) # dept Oise , zicode 60
    @department = @statistician.department
    create(:school, name: 'school 1', zipcode: 60_000, city: 'Coye')
    create(:school, :with_school_manager,  name: 'school 2', zipcode: 75_000) # never ok
    create(:school, :with_school_manager, name: 'school 3',  zipcode: 60_000, city: 'Coye2')
  end

  test 'Offer reporting can be filtered by school_track' do
    sign_in(@statistician)

    visit reporting_dashboards_path(department: @department)
    click_link('Établissements')
    assert_equal "false", find('select#subscribed_school').value
    page.first('strong', text: 'school 1')
    select('Inscrits', from: 'subscribed_school')
    page.first('strong', text: 'school 3')
    select('Tous', from: 'subscribed_school')
    assert page.has_content?('school 1')
    assert page.has_no_content?('school 2')
    assert page.has_content?('school 3')
  end
end