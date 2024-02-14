# frozen_string_literal: true

require 'test_helper'

module Dashboard::Stepper
  class HostingInfosControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    #
    # New HostingInfo
    #
    test 'GET new not logged redirects to sign in' do
      get new_dashboard_stepper_hosting_info_path
      assert_redirected_to user_session_path
    end

    test 'GET #new as employer show valid form' do
      employer = create(:employer)
      sign_in(employer)
      travel_to(Date.new(2019, 3, 1)) do
        organisation = create(:organisation, employer: employer)
        internship_offer_info = create(:internship_offer_info)
        get new_dashboard_stepper_hosting_info_path(organisation_id: organisation.id, internship_offer_info_id: internship_offer_info.id)

        assert_response :success
        available_weeks = Week.selectable_from_now_until_end_of_school_year
        asserted_input_count = 0
        available_weeks.each do |week|
          assert_select "input#hosting_info_week_ids_#{week.id}_checkbox"
          asserted_input_count += 1
        end
        assert asserted_input_count.positive?
      end
    end

    test 'GET #new as employer is not turbolinkable' do
      employer = create(:employer)
      sign_in(employer)
      organisation = create(:organisation, employer: employer)
      internship_offer_info = create(:internship_offer_info)
      
      get new_dashboard_stepper_hosting_info_path(organisation_id: organisation.id, internship_offer_info_id: internship_offer_info.id)
      
      assert_select 'meta[name="turbo-visit-control"][content="reload"]'
    end

    #
    # Create HostingInfo
    #
    test 'POST create redirects to new tutor' do
      employer = create(:employer)
      sign_in(employer)
      weeks = [weeks(:week_2019_1), weeks(:week_2019_2)]
      organisation = create(:organisation, employer: employer)
      internship_offer_info = create(:internship_offer_info)
      assert_difference('HostingInfo.count') do
        post(
          dashboard_stepper_hosting_infos_path(organisation_id: organisation.id, internship_offer_info_id: internship_offer_info.id),
          params: {
            hosting_info: {
              'week_ids' => weeks.map(&:id),
              'max_candidates' => '2',
              'max_students_per_group' => '1'
            },
          })
      end
      created_hosting_info = HostingInfo.last
      assert_equal weeks.map(&:id), created_hosting_info.week_ids
      assert_equal 2, created_hosting_info.max_candidates
      assert_equal 1, created_hosting_info.max_students_per_group
      assert_redirected_to new_dashboard_stepper_practical_info_path(
        organisation_id: organisation.id,
        internship_offer_info_id: internship_offer_info.id,
        hosting_info_id: created_hosting_info.id,
      )
    end

    test 'when statistician POST create redirects to new practical info' do
      statistician = create(:statistician)
      sign_in(statistician)
      weeks = [weeks(:week_2019_1), weeks(:week_2019_2)]
      organisation = create(:organisation, employer: statistician)
      internship_offer_info = create(:internship_offer_info)
      assert_difference('HostingInfo.count') do
        post(
          dashboard_stepper_hosting_infos_path(organisation_id: organisation.id, internship_offer_info_id: internship_offer_info.id),
          params: {
            hosting_info: {
              'week_ids' => weeks.map(&:id),
              'max_candidates' => '2',
              'max_students_per_group' => '1'
            },
          })
      end
      created_hosting_info = HostingInfo.last
      assert_equal weeks.map(&:id), created_hosting_info.week_ids
      assert_equal 2, created_hosting_info.max_candidates
      assert_equal 1, created_hosting_info.max_students_per_group
      assert_redirected_to new_dashboard_stepper_practical_info_path(
        organisation_id: organisation.id,
        internship_offer_info_id: internship_offer_info.id,
        hosting_info_id: created_hosting_info.id,
      )
    end


    test 'POST create render new when missing params, prefill form' do
      employer = create(:employer)
      sign_in(employer)
      sector = create(:sector)
      weeks = [weeks(:week_2019_1)]
      organisation = create(:organisation, employer: employer)
      internship_offer_info = create(:internship_offer_info)
      post(
        dashboard_stepper_hosting_infos_path(organisation_id: organisation.id, internship_offer_info_id: internship_offer_info.id),
        params: {
          hosting_info: {
            max_candidates: 3,
            max_students_per_group: 2,
          }
        })
        assert_response :bad_request
        assert_select '#hosting_info_max_candidates[value="3"]'
        assert_select '#internship_type_true[checked]', count: 0
        assert_select '#internship_type_false[checked]', count: 1
    end


    test 'GET Edit' do
      title = 'ok'
      new_title = 'ko'
      employer = create(:employer)
      organisation = create(:organisation, employer: employer)
      internship_offer_info = create(:internship_offer_info,
                                     employer: employer)
      hosting_info = create(:hosting_info, max_candidates: 2, max_students_per_group: 1, employer: employer)
      sign_in(employer)

      assert_changes -> { hosting_info.reload.max_candidates },
                    from: 2,
                    to: 1 do
        patch(
          dashboard_stepper_hosting_info_path(id: hosting_info.id, organisation_id: organisation.id, internship_offer_info_id: internship_offer_info.id),
          params: {
            hosting_info: hosting_info.attributes.merge({
              max_candidates: 1
            })
          }
        )
        assert_redirected_to new_dashboard_stepper_practical_info_path(
          organisation_id: organisation.id,
          internship_offer_info_id: internship_offer_info.id,
          hosting_info_id: hosting_info.id
        )
      end
    end

    test 'GET #Edit as employer is not turbolinkable' do
      employer = create(:employer)
      organisation = create(:organisation, employer: employer)
      internship_offer_info = create(:internship_offer_info, employer: employer)
      hosting_info = create(:hosting_info, employer: employer)

      sign_in(employer)

      organisation = create(:organisation, employer: employer)
      get edit_dashboard_stepper_hosting_info_path(id: hosting_info.id, organisation_id: organisation.id, internship_offer_info_id: internship_offer_info.id)
      assert_select 'meta[name="turbo-visit-control"][content="reload"]'
    end

  end
end