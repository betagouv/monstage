# frozen_string_literal: true

require 'test_helper'

module Dashboard::Stepper
  class TutorsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #new as employer show valid form' do
      employer = create(:employer)
      sign_in(employer)
      travel_to(Date.new(2019, 3, 1)) do
        organisation = create(:organisation, employer: employer)
        internship_offer_info = create(:weekly_internship_offer_info, weeks: [Week.fetch_from(date: Date.today + 2.weeks)])
        get new_dashboard_stepper_tutor_path(organisation_id: organisation.id,
                                             internship_offer_info_id: internship_offer_info.id)

        assert_response :success
        assert_select 'input[name="tutor[tutor_name]"]'
      end
    end

    test 'GET #new as employer show default values' do
      employer = create(:employer)
      sign_in(employer)
      organisation = create(:organisation, employer: employer)
      internship_offer_info = create(:internship_offer_info)
      get new_dashboard_stepper_tutor_path(organisation_id: organisation.id,
                                            internship_offer_info_id: internship_offer_info.id)

      assert_select('a[href=?]',
                    edit_dashboard_stepper_internship_offer_info_path(
                      id: internship_offer_info.id,
                      internship_offer_info_id: internship_offer_info.id,
                      organisation_id: organisation.id
                    ))
    end

    test 'GET #new as visitor redirects to internship_offers' do
      employer = create(:employer)
      organisation = create(:organisation, employer: employer)
      internship_offer_info = create(:internship_offer_info)
      get new_dashboard_stepper_tutor_path(organisation_id: organisation.id,
                                            internship_offer_info_id: internship_offer_info.id)
      assert_redirected_to user_session_path
    end

    test 'POST #create as visitor redirects to internship_offers' do
      travel_to Date.new(2019, 9, 1) do
        employer = create(:employer)
        internship_offer_info = create(:weekly_internship_offer_info, employer: employer)
        organisation = create(:organisation, employer: employer)
        post(
          dashboard_stepper_tutors_path(organisation_id: organisation.id,
                                        internship_offer_info_id: internship_offer_info.id),
          params: {}
        )
        assert_redirected_to user_session_path
      end
    end

    test 'POST #create/InternshipOffers::WeeklyFramed as employer creates the post' do
      employer = create(:employer)
      sign_in(employer)
      internship_offer_info = create(:weekly_internship_offer_info, employer: employer)
      organisation = create(:organisation, employer: employer)

      assert_difference('InternshipOffer.count', 1) do
        assert_difference('Tutor.count', 1) do
          post(
            dashboard_stepper_tutors_path(organisation_id: organisation.id,
                                          internship_offer_info_id: internship_offer_info.id),
            params: {
              tutor: {
                tutor_name: 'mfo',
                tutor_email: 'mf@oo.com',
                tutor_phone: '0123456789',
                tutor_role: 'opérateur de saisie'
              }
            }
          )
        end
      end
      created_internship_offer = InternshipOffer.last
      created_tutor = Tutor.last

      # recopy internship_offer_info
      assert_equal(internship_offer_info.title,
                   created_internship_offer.title,
                   'title not copied')
      assert_equal(internship_offer_info.max_candidates,
                   created_internship_offer.max_candidates,
                   'max_candidates not copied')
      assert_equal(internship_offer_info.weeks.size,
                   created_internship_offer.internship_offer_weeks_count,
                   'weeks not copied')
      assert_nil(created_internship_offer.school_id,
                 'school_id not copied')
      assert_equal(internship_offer_info.sector_id,
                   created_internship_offer.sector_id,
                   'sector_id not copied')
      assert_equal(InternshipOffers::WeeklyFramed.name,
                   created_internship_offer.type,
                   'type not copied')
      assert_equal(internship_offer_info.weekly_hours,
                   created_internship_offer.weekly_hours,
                   'weekly_hours not copied')
      assert_equal(internship_offer_info.new_daily_hours,
                   created_internship_offer.new_daily_hours,
                   'new_daily_hours not copied')

      # recopy organisation
      assert_equal organisation.employer_name, created_internship_offer.employer_name
      assert_equal organisation.street, created_internship_offer.street
      assert_equal organisation.zipcode, created_internship_offer.zipcode
      assert_equal organisation.city, created_internship_offer.city
      assert_equal organisation.employer_website, created_internship_offer.employer_website
      assert_equal organisation.employer_description, created_internship_offer.employer_description
      assert_equal organisation.coordinates, created_internship_offer.coordinates
      assert_equal organisation.is_public, created_internship_offer.is_public
      assert_equal organisation.group_id, created_internship_offer.group_id

      # recopy tutor
      assert_equal created_tutor.tutor_name, created_internship_offer.tutor_name
      assert_equal created_tutor.tutor_phone, created_internship_offer.tutor_phone
      assert_equal created_tutor.tutor_email, created_internship_offer.tutor_email

      # other feature, with real default
      assert_nil(created_internship_offer.discarded_at,
                 'discarded_at should start with nil')

      assert_in_delta(Time.current,
                      created_internship_offer.published_at,
                      1,
                      'published_at should start with nil')

      assert_equal(employer.id,
                   created_internship_offer.employer_id,
                   'expected default of connected user.id on employer_id')
      assert_equal('User',
                   created_internship_offer.employer_type,
                   'expected default of "User" on employer_type')
      assert_equal("Académie de Paris",
                   created_internship_offer.academy,
                   'academy looked missed')
      assert_not_nil(created_internship_offer.first_date,
                   'first_date not initialized')
      assert_not_nil(created_internship_offer.last_date,
                   'last_date not initialized')

      # keep reference on original step objects
      assert_equal(internship_offer_info.id,
                   created_internship_offer.internship_offer_info_id,
                   'internship_offer_info_id not copied')
      assert_equal(organisation.id,
                   created_internship_offer.organisation_id,
                   'organisation_id not copied')
      assert_equal(created_tutor.id,
                   created_internship_offer.tutor_id,
                   'tutor_id not copied')
 
      assert_redirected_to internship_offer_path(created_internship_offer, origine: 'dashboard')
    end

    test 'POST #create as employer with missing params' do
      travel_to(Time.zone.local(2020, 1, 1)) do
        employer = create(:employer)
        sign_in(employer)
        organisation = create(:organisation, employer: employer)
        internship_offer_info = create(:weekly_internship_offer_info, weeks: [Week.next])
        post(
          dashboard_stepper_tutors_path(organisation_id: organisation.id,
                                        internship_offer_info_id: internship_offer_info.id),
          params: {}
        )
        assert_response :bad_request
      end
    end
  end
end
