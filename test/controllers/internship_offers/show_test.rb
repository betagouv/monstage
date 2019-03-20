require 'test_helper'

module InternshipOffers
  class ShowTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #show displays application form for student' do
      sign_in(create(:student))
      get internship_offer_path(create(:internship_offer))

      assert_response :success
      assert_select "form[id=?]", "new_internship_application"
    end
  end
end
