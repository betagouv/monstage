require 'application_system_test_case'
class ReportingSchoolTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  test 'Offer reporting can be filtered by subscribed_school' do
    @statistician = create(:statistician) # dept Oise , zicode 60
    @department = @statistician.department
    school_1 = create(:school, name: 'unsubscribed school', zipcode: 60_000, city: 'Coye')
    school_2 = create(:school, name: 'parisian subscribing school', zipcode: 75_000) # never ok
    school_3 = create(:school, name: 'oise subscribing school', zipcode: 60_000, city: 'Coye2')
    create(:school_manager, school: school_2)
    create(:school_manager, school: school_3)
    assert_equal ['unsubscribed school'],
                  Reporting::School.by_subscribed_school(subscribed_school: false).pluck(:name),
                  'there should be only 2 unsubscribed schools'
    assert_equal ['oise subscribing school', 'parisian subscribing school'],
                 Reporting::School.by_subscribed_school(subscribed_school: true).pluck(:name).sort,
                 'there should be only 2 unsubscribed schools'
    sign_in(@statistician)

    visit reporting_dashboards_path(department: @department)
    click_link('Établissements')
    assert_equal "false", find('select#subscribed_school').value
    assert page.first('strong', text: 'unsubscribed school')
    assert page.has_no_content?('parisian subscribing school')
    assert page.has_no_content?('oise subscribing school')
    select('Inscrits', from: 'subscribed_school')
    page.first('strong', text: 'oise subscribing school')
    select('Tous', from: 'subscribed_school')
    assert page.has_content?('unsubscribed school')
    assert page.has_no_content?('parisian subscribing school')
    assert page.has_content?('oise subscribing school')
  end

  test 'as god, offer reporting can be filtered by subscribed_school' do
    god = create(:god) # dept Oise , zicode 60
    school_1 = create(:school, name: 'unsubscribed school', zipcode: 60_000, city: 'Coye')
    school_2 = create(:school, name: 'parisian subscribing school', zipcode: 75_000)
    school_3 = create(:school, name: 'oise subscribing school', zipcode: 60_000, city: 'Coye2')
    create(:school_manager, school: school_2)
    create(:school_manager, school: school_3)
    sign_in(god)

    visit reporting_schools_path

    page.first('strong', text: 'unsubscribed school')
    page.first('strong', text: 'parisian subscribing school')
    page.first('strong', text: 'oise subscribing school')
    select('Inscrits', from: 'subscribed_school')
    page.first('strong', text: 'parisian subscribing school')
    page.first('strong', text: 'oise subscribing school')
    select('Tous', from: 'subscribed_school')
    assert page.has_content?('unsubscribed school')
    assert page.has_content?('parisian subscribing school')
    assert page.has_content?('oise subscribing school')
    select('60 - Oise', from: 'department')
    assert page.has_content?('unsubscribed school')
    assert page.has_no_content?('parisian subscribing school')
    assert page.has_content?('oise subscribing school')
    select('Non inscrits', from: 'subscribed_school')
    assert page.has_content?('unsubscribed school')
    assert page.has_no_content?('parisian subscribing school')
    assert page.has_no_content?('oise subscribing school')
    fill_in "user_school_name",	with: "kko"
    assert page.has_content?('Aucun résultat')
    # Filling in search by name resets the other filters
    fill_in "user_school_name",	with: "ois"
    find(".listview-item").click
    assert page.has_no_content?('unsubscribed school')
    assert page.has_no_content?('parisian subscribing school')
    assert page.has_content?('oise subscribing school')
    assert_equal "all", find('select#subscribed_school').value
    assert_equal "", find('select#department').value
    # find(".btn-clear-city").click
    assert_equal "all", find('select#subscribed_school').value
    assert_equal "", find('select#department').value
    assert_equal "", find('input#user_school_name').value

      # TODO Following tests work on local but not on CI
      # fill_in "user_school_name",	with: "oise "
      # find(".listview-item").click
      # # and using any filter resets the name search
      # select('Non inscrits', from: 'subscribed_school')
      # assert_equal "", find('input#user_school_name').value
      # assert page.has_content?('unsubscribed school')
      # assert page.has_no_content?('parisian subscribing school')
      # assert page.has_no_content?('oise subscribing school')
  end
end
