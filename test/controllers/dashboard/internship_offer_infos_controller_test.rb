# frozen_string_literal: true

require 'test_helper'

module Dashboard
  class InternshipOfferInfosControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    #
    # New InternshipOfferInfo
    #
    test 'GET new not logged redirects to sign in' do
      get new_dashboard_internship_offer_info_path
      assert_redirected_to user_session_path
    end

    test 'GET #new as employer show valid form' do
      sign_in(create(:employer))
      travel_to(Date.new(2019, 3, 1)) do
        organisation = create(:organisation)
        get new_dashboard_internship_offer_info_path(organisation_id: organisation.id)

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

    test 'GET #new as employer with duplicate_id with old offer' do
      sign_in(create(:employer))
      organisation = create(:organisation)
      internship_offer = create(:weekly_internship_offer,
        employer_name: 'Apple',
        description: 'ma description',
        max_candidates: 1,
        # school_id: 'Paris',
      )
      get new_dashboard_internship_offer_info_path(organisation_id: organisation.id,
                                                  duplicate_id: internship_offer.id)

      assert_response :success
      available_weeks = Week.selectable_from_now_until_end_of_school_year
      asserted_input_count = 2
      assert_select 'input[name="internship_offer_info[type]"]'
      assert_select 'input[name="internship_offer_info[title]"][value="Apple"]'
      assert_select 'input[name="internship_offer_info[sector_id]"][value="#{internship_offer.sector_id}"]'
      assert_select 'input[name="internship_offer_info[description_rich_text]"][value="ma description"]'
      assert_select 'input[name="internship_offer_info[school_id]"][value="#{internship_offer.school_id}"]'
      assert_select 'input[name="internship_offer_info[max_candidates]"][value="1"]'
      available_weeks.each do |week|
        assert_select "input[id=internship_offer_info_week_ids_#{week.id}]"
        asserted_input_count += 1
      end
    end

    #
    # Create InternshipOfferInfo
    #
    test 'POST create redirects to new mentor' do
      sign_in(create(:employer))
      sector = create(:sector)
      weeks = [weeks(:week_2019_1)]

      post(
        dashboard_internship_offer_infos_path,
        params: {
          internship_offer_info: {
            sector_id: sector.id,
            title: 'PDG stagiaire',
            type: 'InternshipOfferInfos::WeeklyFramedInfo',
            description_rich_text: '<div><b>Activités de découverte</b></div>',
            'week_ids' => weeks.map(&:id),
            organisation_id: 1
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
      created_internship_offer_info = InternshipOfferInfo.last
      assert_equal 'PDG stagiaire', created_internship_offer_info.title
      assert_equal sector.id, created_internship_offer_info.sector_id
      assert_equal 'InternshipOfferInfos::WeeklyFramedInfo', created_internship_offer_info.type
      assert_equal 'Activités de découverte', created_internship_offer_info.description
      assert_equal [["10:00", "13:00"], ["9:00", "17:00"], ["9:00", "17:00"], ["9:00", "17:00"], ["9:00", "17:00"], ['', '']], created_internship_offer_info.daily_hours
      assert_equal weeks.map(&:id), created_internship_offer_info.week_ids
      assert_redirected_to new_dashboard_internship_offer_path(
        organisation_id: 1,
        internship_offer_info_id: created_internship_offer_info.id,
      )
    end

    
    test 'POST create render new when missing params, prefill form' do
      sign_in(create(:employer))
      sector = create(:sector)
      weeks = [weeks(:week_2019_1)]

      post(
        dashboard_internship_offer_infos_path,
        params: {
          internship_offer_info: {
            sector_id: sector.id,
            type: 'InternshipOfferInfos::FreeDateInfo',
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
  end
end
