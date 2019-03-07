require 'test_helper'


module InternshipOffers
  class NewTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #new as employer show valid form' do
      sign_in(create(:employer)) do
        travel_to(Date.new(2019, 3, 1)) do
          get new_internship_offer_path

          assert_response :success
          assert_select 'select[name="internship_offer[week_ids][]"] option', 14
          assert_select 'option', text: 'Semaine 9 - du 25/02/19 au 03/03/19'
          assert_select 'option', text: 'Semaine 10 - du 04/03/19 au 10/03/19'
          assert_select 'option', text: 'Semaine 11 - du 11/03/19 au 17/03/19'
          assert_select 'option', text: 'Semaine 12 - du 18/03/19 au 24/03/19'
          assert_select 'option', text: 'Semaine 13 - du 25/03/19 au 31/03/19'
          assert_select 'option', text: 'Semaine 14 - du 01/04/19 au 07/04/19'
          assert_select 'option', text: 'Semaine 15 - du 08/04/19 au 14/04/19'
          assert_select 'option', text: 'Semaine 16 - du 15/04/19 au 21/04/19'
          assert_select 'option', text: 'Semaine 17 - du 22/04/19 au 28/04/19'
          assert_select 'option', text: 'Semaine 18 - du 29/04/19 au 05/05/19'
          assert_select 'option', text: 'Semaine 19 - du 06/05/19 au 12/05/19'
          assert_select 'option', text: 'Semaine 20 - du 13/05/19 au 19/05/19'
          assert_select 'option', text: 'Semaine 21 - du 20/05/19 au 26/05/19'
          assert_select 'option', text: 'Semaine 22 - du 27/05/19 au 02/06/19'
        end
      end
    end

    test 'GET #new as visitor redirects to internship_offers' do
      get new_internship_offer_path
      assert_redirected_to root_path
    end
  end
end
