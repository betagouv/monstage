require 'test_helper'

module InternshipOffers
  class FlashTest  < ActionDispatch::IntegrationTest
    include SessionManagerTestHelper

    test 'flash presence' do
      get new_internship_offer_path
      follow_redirect!
      assert_select("#alert-danger",
                    { text: "Vous n'êtes pas autorisé à créer une annonce" },
                    'missing flash rendering')
    end
  end
end
