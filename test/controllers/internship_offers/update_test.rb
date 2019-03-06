require 'test_helper'


module InternshipOffers
  class UpdateTest < ActionDispatch::IntegrationTest
    include SessionManagerTestHelper

    test 'PATCH #update as employer updates internship_offer' do
      internship_offer = create(:internship_offer)
      new_title = 'new title'

      sign_in(as: MockUser::Employer) do
        patch(internship_offer_path(internship_offer.to_param),
              params: { internship_offer: {
                          title: new_title,
                          week_ids: [weeks(:week_2019_1).id],
                          is_public: false,
                          can_be_applied_for: false
                        }
                      })
        assert_redirected_to(internship_offer,
                           'redirection should point to updated offer')
        assert_equal(new_title,
                     internship_offer.reload.title,
                     'can\'t update internship_offer title')
      end
    end
  end
end
