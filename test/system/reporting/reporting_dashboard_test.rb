require 'application_system_test_case'
class ReportingDashboardTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @statistician = create(:statistician)
    @sector_agri = create(:sector, name: 'Agriculture')
    @sector_wood = create(:sector, name: 'Filière bois')
    @group1 = create(:group, name: 'group1', is_public: true)
    @group2 = create(:group, name: 'group2', is_public: true)
    @department = @statistician.department # Oise
    @school_with_segpa = create(
      :school_with_troisieme_segpa_class_room,
      :with_school_manager,
      zipcode: 60_000 # Oise
    )
  end

  test 'Offers are filtered by school_track' do
    create(:troisieme_prepa_metiers_internship_offer, zipcode: 60_000)
    3.times { create(:troisieme_generale_internship_offer,
                     zipcode: 60_000,
                     group: @group1)
    }
    2.times { create(:troisieme_segpa_internship_offer,
                     zipcode: 60_000,
                     group: @group2)
    }
    sign_in(@statistician)
    visit reporting_dashboards_path(department: @department)
    @total_offers_css = 'span.ml-auto.h2.text-warning'
    page.assert_selector(@total_offers_css, text: '6')
    find_link('Offres').click

    total_report_css = 'tfoot .test-total-report'

    select '3ème'
    page.assert_selector(total_report_css, text: '3')

    select '3e SEGPA'
    page.assert_selector(total_report_css, text: '2')
  end
end
