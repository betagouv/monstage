require 'test_helper'

class IndexTest < ActionDispatch::IntegrationTest
  include SessionManagerTestHelper

  test 'GET #index as student. check if filters are properly populated' do
    week = Week.find_by(year: 2019, number: 10)
    create(:internship_offer, sector: "Animaux", weeks: [week])
    create(:internship_offer, sector: "Droit, Justice", weeks: [week])
    create(:internship_offer, sector: "Mode, Luxe, Industrie textile", weeks: [week])
    student = create(:student)

    sign_in(as: student) do
      travel_to(Date.new(2019, 3, 1)) do
        get internship_offers_path

        assert_response :success
        assert_select 'select#internship-offer-sector-filter option', 3
        assert_select 'option', text: "Animaux"
        assert_select 'option', text: "Droit, Justice"
        assert_select 'option', text: "Mode, Luxe, Industrie textile"
      end
    end
  end
end
