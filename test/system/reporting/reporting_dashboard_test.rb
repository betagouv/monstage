require 'application_system_test_case'
class ReportingDashboardTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @statistician = create(:statistician)
    @sector_agri = create(:sector, name: 'Agriculture')
    @sector_wood = create(:sector, name: 'Filière bois')
    @group1 = create(:group, name: 'group1', is_public: true)
    @group2 = create(:group, name: 'group2', is_public: true)
    @department_name = @statistician.department_name # Oise
    @school_with_segpa = create(
      :school_with_troisieme_segpa_class_room,
      :with_school_manager,
      zipcode: 60_000 # Oise
    )
  end

  test 'School reporting can be filtered by school_track' do
    sign_in(@statistician)
    visit reporting_dashboards_path(department: @department_name)

    @total_schools_with_manager_css = 'p.col-6.text-left > span.h2.text-body'
    page.assert_selector(
      @total_schools_with_manager_css,
      text: '1'
    )
    select '3e générale'
    page.assert_selector(
      @total_schools_with_manager_css,
      text: '0'
    )
    select '3e SEGPA'
    page.assert_selector(
      @total_schools_with_manager_css,
      text: '1'
    )
  end

  test 'Offers are filtered by school_track' do
    create(:troisieme_prepa_metier_internship_offer, zipcode: 60_000)
    3.times { create(:troisieme_generale_internship_offer,
                     zipcode: 60_000,
                     group: @group1)
    }
    2.times { create(:troisieme_segpa_internship_offer,
                     zipcode: 60_000,
                     group: @group2)
    }
    sign_in(@statistician)
    visit reporting_dashboards_path(department: @department_name)
    @total_offers_css = 'span.ml-auto.h2.text-warning'

    page.assert_selector(@total_offers_css, text: '6')

    select '3e générale'
    page.assert_selector(@total_offers_css, text: '3')
    assert page.find('td', text: 'group1')
               .has_sibling?('td', text: '3')
    assert page.find('td', text: 'group2')
               .has_sibling?('td', text: '0')

    select '3e SEGPA'
    page.assert_selector(@total_offers_css, text: '2')
    assert page.find('td', text: 'group1')
               .has_sibling?('td', text: '0')
    assert page.find('td', text: 'group2')
               .has_sibling?('td', text: '2')
  end
end
