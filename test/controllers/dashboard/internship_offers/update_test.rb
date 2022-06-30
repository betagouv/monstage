# frozen_string_literal: true

require 'test_helper'

module Dashboard::InternshipOffers
  class UpdateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'PATCH #update as visitor redirects to user_session_path' do
      internship_offer = create(:weekly_internship_offer)
      patch(dashboard_internship_offer_path(internship_offer.to_param), params: {})
      assert_redirected_to user_session_path
    end

    test 'PATCH #update as employer not owning internship_offer redirects to user_session_path' do
      internship_offer = create(:weekly_internship_offer)
      sign_in(create(:employer))
      patch(dashboard_internship_offer_path(internship_offer.to_param), params: { internship_offer: { title: '' } })
      assert_redirected_to root_path
    end

    test 'PATCH #update as employer owning internship_offer updates internship_offer' do
      internship_offer = create(:weekly_internship_offer)
      new_title = 'new title'
      new_group = create(:group, is_public: false, name: 'woop')
      sign_in(internship_offer.employer)
      patch(dashboard_internship_offer_path(internship_offer.to_param),
            params: { internship_offer: {
              title: new_title,
              week_ids: [weeks(:week_2019_1).id],
              is_public: false,
              group_id: new_group.id,
              new_daily_hours: {'lundi' => ['10h', '12h']}

            } })
      assert_redirected_to(internship_offer_path(internship_offer),
                           'redirection should point to updated offer')

      assert_equal(new_title,
                   internship_offer.reload.title,
                   'can\'t update internship_offer title')
      assert_equal ['10h', '12h'], internship_offer.reload.new_daily_hours['lundi']

    end

    test 'PATCH #update as statistician owning internship_offer updates internship_offer' do
      internship_offer = create(:weekly_internship_offer)
      statistician = create(:statistician)
      internship_offer.update(employer_id: statistician.id)
      new_title = 'new title'
      new_group = create(:group, is_public: false, name: 'woop')
      sign_in(statistician)
      patch(dashboard_internship_offer_path(internship_offer.to_param),
            params: { internship_offer: {
              title: new_title,
              week_ids: [weeks(:week_2019_1).id],
              is_public: false,
              group_id: new_group.id,
              new_daily_hours: {'lundi' => ['10h', '12h']}

            } })
      assert_redirected_to(internship_offer_path(internship_offer),
                           'redirection should point to updated offer')

      assert_equal(new_title,
                   internship_offer.reload.title,
                   'can\'t update internship_offer title')
      assert_equal ['10h', '12h'], internship_offer.reload.new_daily_hours['lundi']

    end

    test 'PATCH #update as employer owning internship_offer can publish/unpublish offer' do
      internship_offer = create(:weekly_internship_offer)
      published_at = 2.days.ago.utc
      sign_in(internship_offer.employer)
      assert_changes -> { internship_offer.reload.published_at.to_i },
                     from: internship_offer.published_at.to_i,
                     to: published_at.to_i do
        patch(dashboard_internship_offer_path(internship_offer.to_param),
              params: { internship_offer: { published_at: published_at } })
      end
    end

    test 'PATCH #update as employer is able to remove school' do
      school = create(:school)
      internship_offer = create(:weekly_internship_offer, school: school)
      sign_in(internship_offer.employer)
      assert_changes -> { internship_offer.reload.school },
                     from: school,
                     to: nil do
        patch(dashboard_internship_offer_path(internship_offer.to_param),
              params: { internship_offer: { school_id: nil } })
      end
    end
  end
end
