require 'test_helper'

class InternshipOffersControllerTest < ActionDispatch::IntegrationTest
  test "test presence of weeks" do
    travel_to(Date.new(2019, 2, 15)) do
      get new_internship_offer_path

      assert_select "select#excluded_week_ids option", 12
      assert_select "option", text: "Semaine 7 - du 11/02/19 au 17/02/19"
      assert_select "option", text: "Semaine 8 - du 18/02/19 au 24/02/19"
      assert_select "option", text: "Semaine 9 - du 25/02/19 au 03/03/19"
      assert_select "option", text: "Semaine 10 - du 04/03/19 au 10/03/19"
      assert_select "option", text: "Semaine 11 - du 11/03/19 au 17/03/19"
      assert_select "option", text: "Semaine 12 - du 18/03/19 au 24/03/19"
      assert_select "option", text: "Semaine 13 - du 25/03/19 au 31/03/19"
      assert_select "option", text: "Semaine 14 - du 01/04/19 au 07/04/19"
      assert_select "option", text: "Semaine 15 - du 08/04/19 au 14/04/19"
      assert_select "option", text: "Semaine 16 - du 15/04/19 au 21/04/19"
      assert_select "option", text: "Semaine 17 - du 22/04/19 au 28/04/19"
      assert_select "option", text: "Semaine 18 - du 29/04/19 au 05/05/19"
    end
  end
end
