# frozen_string_literal: true

require 'test_helper'

module Dashboard::Stepper
  class InternshipOfferInfosControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    #
    # New InternshipOfferInfo
    #
    test 'GET new not logged redirects to sign in' do
      get new_dashboard_stepper_internship_offer_info_path
      assert_redirected_to user_session_path
    end

    test 'GET #new as employer show valid form' do
      employer = create(:employer)
      sign_in(employer)
      travel_to(Date.new(2019, 3, 1)) do
        organisation = create(:organisation, employer: employer)
        get new_dashboard_stepper_internship_offer_info_path(organisation_id: organisation.id)

        assert_response :success
        available_weeks = Week.selectable_from_now_until_end_of_school_year
        asserted_input_count = 0
        available_weeks.each do |week|
          assert_select "input[id=internship_offer_info_week_ids_#{week.id}]"
          asserted_input_count += 1
        end
        assert asserted_input_count.positive?
      end
    end

    #
    # Create InternshipOfferInfo
    #
    test 'POST create redirects to new tutor' do
      employer = create(:employer)
      sign_in(employer)
      sector = create(:sector)
      weeks = [weeks(:week_2019_1)]
      organisation = create(:organisation, employer: employer)
      assert_difference('InternshipOfferInfo.count') do
        post(
          dashboard_stepper_internship_offer_infos_path(organisation_id: organisation.id),
          params: {
            internship_offer_info: {
              sector_id: sector.id,
              title: 'PDG stagiaire',
              type: 'InternshipOfferInfos::WeeklyFramed',
              description_rich_text: '<div><b>Activités de découverte</b></div>',
              'week_ids' => weeks.map(&:id),
            },
            daily_start_0: '10:00',
            daily_end_0: '13:00',
            daily_start_1: '9:00',
            daily_end_1: '17:00',
            daily_start_2: '9:00',
            daily_end_2: '17:00',
            daily_start_3: '9:00',
            daily_end_3: '17:00',
            daily_start_4: '9:00',
            daily_end_4: '17:00',
            daily_start_5: '',
            daily_end_5: ''
          })
      end
      created_internship_offer_info = InternshipOfferInfo.last
      assert_equal 'PDG stagiaire', created_internship_offer_info.title
      assert_equal sector.id, created_internship_offer_info.sector_id
      assert_equal 'InternshipOfferInfos::WeeklyFramed', created_internship_offer_info.type
      assert_equal 'Activités de découverte', created_internship_offer_info.description_rich_text.to_plain_text
      assert_equal [["10:00", "13:00"], ["9:00", "17:00"], ["9:00", "17:00"], ["9:00", "17:00"], ["9:00", "17:00"], ['', '']], created_internship_offer_info.daily_hours
      assert_equal weeks.map(&:id), created_internship_offer_info.week_ids
      assert_redirected_to new_dashboard_stepper_tutor_path(
        organisation_id: organisation.id,
        internship_offer_info_id: created_internship_offer_info.id,
      )
    end


    test 'POST create render new when missing params, prefill form' do
      employer = create(:employer)
      sign_in(employer)
      sector = create(:sector)
      weeks = [weeks(:week_2019_1)]
      organisation = create(:organisation, employer: employer)
      post(
        dashboard_stepper_internship_offer_infos_path(organisation_id: organisation.id),
        params: {
          internship_offer_info: {
            sector_id: sector.id,
            type: 'InternshipOfferInfos::FreeDate',
            description_rich_text: '<div><b>Activités de découverte</b></div>',
            'week_ids' => weeks.map(&:id),
            organisation_id: 1,
            max_candidates: 3
          }
        })
        assert_response :bad_request
        assert_select '#internship_offer_info_max_candidates[value="3"]'
        assert_select '#internship_type_true[checked]', count: 0
        assert_select '#internship_type_false[checked]', count: 1
    end

    # todo, prevent editing other internship_offer_info
    test 'GET Edit' do
      title = 'ok'
      new_title = 'ko'
      employer = create(:employer)
      organisation = create(:organisation, employer: employer)
      internship_offer_info = create(:weekly_internship_offer_info,
                                     employer: employer,
                                     title: title)
      sign_in(employer)
      assert_changes -> { internship_offer_info.reload.title },
                    from: title,
                    to: new_title do
        patch(
          dashboard_stepper_internship_offer_info_path(id: internship_offer_info.id, organisation_id: organisation.id),
          params: {
            internship_offer_info: internship_offer_info.attributes.merge({
              title: new_title,
            })
          }
        )
        assert_redirected_to new_dashboard_stepper_tutor_path(
          organisation_id: organisation.id,
          internship_offer_info_id: internship_offer_info.id,
        )
      end

      # TODO : test patch update!
    end
  end
end
