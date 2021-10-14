# frozen_string_literal: true

require 'test_helper'

module Dashboard::Stepper
  class TutorsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #new as employer show valid form' do
      employer = create(:employer)
      sign_in(employer)
      travel_to(Date.new(2019, 3, 1)) do
        organisation = create(:organisation, creator_id: employer.id)
        internship_offer_info = create(:internship_offer_info)
        get new_dashboard_stepper_tutor_path(organisation_id: organisation.id,
                                             internship_offer_info_id: internship_offer_info.id)

        assert_response :success
        assert_select 'input[name="tutor[first_name]"]'
      end
    end

    test 'GET #new as employer show default values' do
      employer = create(:employer)
      sign_in(employer)
      organisation = create(:organisation, creator_id: employer.id)
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
      organisation = create(:organisation, creator_id: employer.id)
      internship_offer_info = create(:internship_offer_info)
      get new_dashboard_stepper_tutor_path(organisation_id: organisation.id,
                                            internship_offer_info_id: internship_offer_info.id)
      assert_redirected_to user_session_path
    end

    test 'POST #createas visitor redirects to internship_offers' do
      employer = create(:employer)
      internship_offer_info = create(:weekly_internship_offer_info, employer: employer)
      organisation = create(:organisation, creator_id: employer.id)
      post(
        dashboard_stepper_tutors_path(organisation_id: organisation.id,
                                       internship_offer_info_id: internship_offer_info.id),
        params: {}
      )
      assert_redirected_to user_session_path
    end

    test 'POST #create/InternshipOffers::WeeklyFramed as employer creates the post' do
      employer = create(:employer)
      sign_in(employer)
      internship_offer_info = create(:weekly_internship_offer_info, employer: employer)
      organisation = create(:organisation, creator_id: employer.id)

      assert_enqueued_jobs 0, only: SendSmsJob do
        assert_difference('InternshipOffer.count', 1) do
          assert_difference('Users::Tutor.count', 1) do
            post(
              dashboard_stepper_tutors_path(organisation_id: organisation.id,
                                            internship_offer_info_id: internship_offer_info.id),
              params: {
                tutor: {
                  first_name: 'mfo', last_name: 'Dupont', email: 'mf@oo.com', phone: '+330623456789'
                }
              }
            )
          end
        end
      end
      created_internship_offer = InternshipOffer.last
      created_tutor = Users::Tutor.last

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
      assert_equal(internship_offer_info.school_track,
                   created_internship_offer.school_track,
                   'school_track not copied')

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
      assert_equal created_tutor.first_name, created_internship_offer.tutor.first_name
      assert_equal created_tutor.last_name, created_internship_offer.tutor.last_name
      assert_equal created_tutor.phone, created_internship_offer.tutor.phone
      assert_equal created_tutor.email, created_internship_offer.tutor.email
      assert_not_nil created_tutor.confirmed_at, 'shoud be confirmed'
      assert_nil created_tutor.phone_token, 'phone shoud be confirmed'

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
      assert_equal(internship_offer_info.school_track,
                   created_internship_offer.school_track,
                   'school_track not copied')

      assert_redirected_to internship_offer_path(created_internship_offer, origin: 'dashboard')
    end

    test 'POST #create/InternshipOffers::WeeklyFramed as employer with employer tutor account creates tutor' do
      employer = create(:employer)
      another_employer = create(:employer)
      sign_in(employer)
      internship_offer_info = create(:weekly_internship_offer_info, employer: employer)
      organisation = create(:organisation, creator_id: employer.id)

      assert_difference('InternshipOffer.count', 1) do
        assert_difference('Users::Tutor.count', 0) do
          post(
            dashboard_stepper_tutors_path(organisation_id: organisation.id,
                                          internship_offer_info_id: internship_offer_info.id),
            params: {
              tutor: {
                first_name: 'mfo', last_name: 'Dupont', email: another_employer.email, phone: '+330623456789'
              }
            }
          )
        end
      end

      created_internship_offer = InternshipOffer.last
      assert_equal created_internship_offer.tutor_id, another_employer.id
    end

    test 'POST #create/InternshipOffers::WeeklyFramed as employer with same tutor email does not create tutor' do
      employer = create(:employer)
      sign_in(employer)
      internship_offer_info = create(:weekly_internship_offer_info, employer: employer)
      organisation = create(:organisation, creator_id: employer.id)

      assert_difference('InternshipOffer.count', 1) do
        assert_difference('Users::Tutor.count', 0) do
          post(
            dashboard_stepper_tutors_path(organisation_id: organisation.id,
                                          internship_offer_info_id: internship_offer_info.id),
            params: {
              tutor: {
                first_name: 'mfo', last_name: 'Dupont', email: employer.email, phone: '+330623456789'
              }
            }
          )
        end
      end
    end


    test 'POST #create/InternshipOffers::FreeDate as employer creates the post' do
      employer = create(:employer)
      sign_in(employer)
      school = create(:school)
      internship_offer_info = create(:free_date_internship_offer_info)
      organisation = create(:organisation, creator_id: employer.id)
      mock_mail = MiniTest::Mock.new
      mock_mail.expect(:deliver_later, true)

      TutorMailer.stub :new_tutor, mock_mail do
        assert_difference('InternshipOffer.count', 1) do
          post(
            dashboard_stepper_tutors_path(organisation_id: organisation.id,
                                          internship_offer_info_id: internship_offer_info.id),
            params: {
              tutor: {
                first_name: 'mfo', last_name: 'Dupont', email: 'mf@oo.com', phone: '+330611223344'
              }
            }
          )
        end
      end

      mock_mail.verify
      created_internship_offer = InternshipOffer.last
      assert_equal InternshipOffers::FreeDate.name, created_internship_offer.type
      assert_equal employer, created_internship_offer.employer
      assert_nil created_internship_offer.school
      assert_equal(internship_offer_info.school_track,
                   created_internship_offer.school_track,
                   'school_track not copied')
      assert_redirected_to internship_offer_path(created_internship_offer, origin: 'dashboard')
    end

    test 'POST #create/InternshipOffers::FreeDate as statistician creates the post' do
      statistician = create(:statistician)
      sign_in(statistician)
      school = create(:school)
      internship_offer_info = create(:free_date_internship_offer_info)
      organisation = create(:organisation, creator: statistician)

      assert_difference('InternshipOffer.count', 1) do
        post(
          dashboard_stepper_tutors_path(organisation_id: organisation.id,
                                        internship_offer_info_id: internship_offer_info.id),
          params: {
            tutor: {
              first_name: 'mfo', last_name: 'Martin', email: 'mf@oo.com', phone: '+330613456789'
            }
          }
        )
      end
      created_internship_offer = InternshipOffer.last
      assert_equal InternshipOffers::FreeDate.name, created_internship_offer.type
      assert_equal statistician, created_internship_offer.employer
      assert_nil created_internship_offer.school
      assert_equal(internship_offer_info.school_track,
                   created_internship_offer.school_track,
                   'school_track not copied')
      assert_redirected_to internship_offer_path(created_internship_offer, origin: 'dashboard')
    end

    test 'POST #create/InternshipOffers::FreeDate duplicate' do
      school = create(:school)
      employer = create(:employer)
      internship_offer_info = create(:weekly_internship_offer_info, employer: employer)
      organisation = create(:organisation, creator_id: employer.id)
      internship_offer = build(:weekly_internship_offer, employer: employer)
      sign_in(employer)
      assert_difference('InternshipOffer.count', 1) do
        post(
          dashboard_stepper_tutors_path(organisation_id: organisation.id,
                                        internship_offer_info_id: internship_offer_info.id),
          params: {
            tutor: {
              first_name: 'mfo', last_name: 'Dupont', email: 'mf@oo.com', phone: '+330611223344'
            }
          }
        )
      end
      follow_redirect!
      assert_select('#alert-text', text:'Votre offre de stage est désormais en ligne, Vous pouvez à tout moment la supprimer ou la modifier.')
    end

    test 'POST #create as employer with missing params' do
      employer = create(:employer)
      sign_in(employer)
      organisation = create(:organisation, creator_id: employer.id)
      internship_offer_info = create(:internship_offer_info)
      post(
        dashboard_stepper_tutors_path(organisation_id: organisation.id,
                                      internship_offer_info_id: internship_offer_info.id),
        params: {}
      )
      assert_response :bad_request
    end
  end
end
