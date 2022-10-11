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

  test 'Offers deleted are displayed' do
    travel_to(Date.new(2020, 9, 3)) do
      3.times { create(:weekly_internship_offer,
                       zipcode: 60_000,
                       group: @group1)
      }
      create(:weekly_internship_offer,
                       zipcode: 60_000,
                       group: @group1).discard!
      sign_in(@statistician)
      visit reporting_dashboards_path(department: @department, school_year: 2020)

      find_link('Tableau de bord').click
    end
  end
end
