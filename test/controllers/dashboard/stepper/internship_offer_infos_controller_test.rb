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
          assert_select "input#internship_offer_info_week_ids_#{week.id}_checkbox"
          asserted_input_count += 1
        end
        assert asserted_input_count.positive?
      end
    end

    test 'GET #new as employer is not turbolinkable' do
      employer = create(:employer)
      sign_in(employer)
      organisation = create(:organisation, employer: employer)
      get new_dashboard_stepper_internship_offer_info_path(organisation_id: organisation.id)
      assert_select 'meta[name="turbo-visit-control"][content="reload"]'
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
              employer_name: 'Café de la Paix',
              street: '2 rue de la paix',
              city: 'Paris',
              zipcode: '75002',
              coordinates: Coordinates.paris,
              'week_ids' => weeks.map(&:id),
              new_daily_hours: {
                "lundi" => ['07:00', '12:00'],
                "mardi" => ['08:00', '13:00'],
                "mercredi" => ['09:00', '14:00'],
                "jeudi" => ['10:00', '15:00'],
                "vendredi" => ['11:00', '16:00'],
                "samedi" => ['--', '--']
              }
            },
          })
      end
      created_internship_offer_info = InternshipOfferInfo.last
      assert_equal 'PDG stagiaire', created_internship_offer_info.title
      assert_equal sector.id, created_internship_offer_info.sector_id
      assert_equal 'InternshipOfferInfos::WeeklyFramed', created_internship_offer_info.type
      assert_equal 'Activités de découverte', created_internship_offer_info.description_rich_text.to_plain_text
      assert_equal ['07:00', '12:00'], created_internship_offer_info.new_daily_hours["lundi"]
      assert_equal ['08:00', '13:00'], created_internship_offer_info.new_daily_hours["mardi"]
      assert_equal ['09:00', '14:00'], created_internship_offer_info.new_daily_hours["mercredi"]
      assert_equal ['10:00', '15:00'], created_internship_offer_info.new_daily_hours["jeudi"]
      assert_equal ['11:00', '16:00'], created_internship_offer_info.new_daily_hours["vendredi"]
      assert_equal ['--', '--'], created_internship_offer_info.new_daily_hours["samedi"]
      assert_equal weeks.map(&:id), created_internship_offer_info.week_ids
      assert_redirected_to new_dashboard_stepper_tutor_path(
        organisation_id: organisation.id,
        internship_offer_info_id: created_internship_offer_info.id,
      )
    end

    test 'when statistician POST create redirects to new tutor' do
      statistician = create(:statistician)
      sign_in(statistician)
      sector = create(:sector)
      weeks = [weeks(:week_2019_1)]
      organisation = create(:organisation, employer: statistician)
      assert_difference('InternshipOfferInfo.count') do
        post(
          dashboard_stepper_internship_offer_infos_path(organisation_id: organisation.id),
          params: {
            internship_offer_info: {
              sector_id: sector.id,
              title: 'PDG stagiaire',
              type: 'InternshipOfferInfos::WeeklyFramed',
              description_rich_text: '<div><b>Activités de découverte</b></div>',
              employer_name: 'Café de la Paix',
              street: '2 rue de la paix',
              city: 'Paris',
              zipcode: '75002',
              coordinates: Coordinates.paris,
              'week_ids' => weeks.map(&:id),
              new_daily_hours: {
                "lundi" => ['07:00', '12:00'],
                "mardi" => ['08:00', '13:00'],
                "mercredi" => ['09:00', '14:00'],
                "jeudi" => ['10:00', '15:00'],
                "vendredi" => ['11:00', '16:00'],
                "samedi" => ['--', '--']
              }
            },
          })
      end
      created_internship_offer_info = InternshipOfferInfo.last
      assert_equal 'PDG stagiaire', created_internship_offer_info.title
      assert_equal sector.id, created_internship_offer_info.sector_id
      assert_equal 'InternshipOfferInfos::WeeklyFramed', created_internship_offer_info.type
      assert_equal 'Activités de découverte', created_internship_offer_info.description_rich_text.to_plain_text
      assert_equal ['07:00', '12:00'], created_internship_offer_info.new_daily_hours["lundi"]
      assert_equal ['08:00', '13:00'], created_internship_offer_info.new_daily_hours["mardi"]
      assert_equal ['09:00', '14:00'], created_internship_offer_info.new_daily_hours["mercredi"]
      assert_equal ['10:00', '15:00'], created_internship_offer_info.new_daily_hours["jeudi"]
      assert_equal ['11:00', '16:00'], created_internship_offer_info.new_daily_hours["vendredi"]
      assert_equal ['--', '--'], created_internship_offer_info.new_daily_hours["samedi"]
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
            type: 'InternshipOfferInfos::WeeklyFramed',
            description_rich_text: '<div><b>Activités de découverte</b></div>',
            'week_ids' => weeks.map(&:id),
            organisation_id: 1,
            max_candidates: 3,
            max_students_per_group: 3,
            weekly_hours: ['10h', '12h'],
            employer_name: 'test',
            city: 'Paris',
            zip_code: '75002',
            street: '2 rue de la paix',
            coordinates: Coordinates.paris
          }
        })
        assert_response :bad_request
        assert_select '#internship_offer_info_max_candidates[value="3"]'
        assert_select '#internship_type_true[checked]', count: 0
        assert_select '#internship_type_false[checked]', count: 1
    end


    test 'GET Edit' do
      title = 'ok'
      new_title = 'ko'
      employer = create(:employer)
      organisation = create(:organisation, employer: employer)
      internship_offer_info = create(:weekly_internship_offer_info,
                                     employer: employer,
                                     title: title)
      create(:weekly_internship_offer,
        organisation: organisation,
        internship_offer_info: internship_offer_info
      )
      sign_in(employer)
      assert_changes -> { internship_offer_info.reload.title },
                    from: title,
                    to: new_title do
        patch(
          dashboard_stepper_internship_offer_info_path(
            id: internship_offer_info.id,
            organisation_id: organisation.id),
          params: {
            internship_offer_info: internship_offer_info.attributes.merge({
              title: new_title,
            })
          }
        )
        # assert_redirected_to new_dashboard_stepper_tutor_path(
        #   organisation_id: organisation.id,
        #   internship_offer_info_id: internship_offer_info.id,
        # )
      end
    end

    test 'GET #Edit as employer is not turbolinkable' do
      employer = create(:employer)
      organisation = create(:organisation, employer: employer)
      internship_offer_info = create(:weekly_internship_offer_info, employer: employer)
      sign_in(employer)
      organisation = create(:organisation, employer: employer)
      get edit_dashboard_stepper_internship_offer_info_path(id: internship_offer_info.id, organisation_id: organisation.id)
      assert_select 'meta[name="turbo-visit-control"][content="reload"]'
    end

    test 'PATCH #update as employer is able to remove school' do
      school = create(:school)

      internship_offer_info = create(:weekly_internship_offer_info, school: school)
      employer = internship_offer_info.employer
      organisation = create(:organisation, employer: employer)
      tutor = create(:tutor, employer_id: employer.id)
      internship_offer = create(:weekly_internship_offer,
                                employer: employer,
                                organisation_id: organisation.id,
                                internship_offer_info_id: internship_offer_info.id,
                                tutor_id: tutor.id,
                                school: school)
      sign_in(internship_offer.employer)
      assert_changes -> { internship_offer.reload.school },
                    from: school,
                    to: nil do
        patch(dashboard_stepper_internship_offer_info_path(internship_offer_info.to_param),
              params: { internship_offer_info: { school_id: nil } })
      end
    end

    test 'PATCH #update as employer not owning internship_offer redirects to user_session_path' do
      internship_offer_info = create(:weekly_internship_offer_info)
      employer = internship_offer_info.employer
      organisation = create(:organisation, employer: employer)
      tutor = create(:tutor, employer_id: employer.id)
      internship_offer = create(:weekly_internship_offer, employer: employer, organisation_id: organisation.id, internship_offer_info_id: internship_offer_info.id, tutor_id: tutor.id)
      sign_in(create(:employer))
      patch(dashboard_stepper_internship_offer_info_path(internship_offer_info.to_param), params: { internship_offer: { title: '' } })
      assert_redirected_to root_path
    end

    test 'PATCH #update as employer owning internship_offer updates internship_offer' do
      # internship_offer = create(:weekly_internship_offer)
      internship_offer_info = create(:weekly_internship_offer_info)
      employer = internship_offer_info.employer
      organisation = create(:organisation, employer: employer)
      tutor = create(:tutor, employer_id: employer.id)
      internship_offer = create(:weekly_internship_offer, employer: employer, organisation_id: organisation.id, internship_offer_info_id: internship_offer_info.id, tutor_id: tutor.id)
      # weeks = Week.selectable_from_now_until_end_of_school_year.last(4)
      new_title = 'new title'
      new_group = create(:group, is_public: false, name: 'woop')
      assert_equal employer.id, internship_offer.employer.id
      sign_in(employer)
      patch(dashboard_stepper_internship_offer_info_path(internship_offer_info.to_param),
            params: {
              commit: "Modifier les informations de stage",
              internship_offer_info: {
                title: new_title,
                week_ids: [weeks(:week_2019_1).id],
                new_daily_hours: {'lundi' => ['10h', '12h']}
              }
            }
          )
      assert_redirected_to(edit_dashboard_internship_offer_path(internship_offer.to_param, step: 2),
                          'redirection should point to updated offer')

      assert_equal(new_title,
                  internship_offer.reload.title,
                  'can\'t update internship_offer title')
      assert_equal ['10h', '12h'], internship_offer.reload.new_daily_hours['lundi']

    end

    test 'PATCH #update as employer owning internship_offer ' \
        'updates internship_offer ' do
      weeks = Week.all.first(3)
      week_ids = weeks.map(&:id)
      internship_offer_info = create(:weekly_internship_offer_info)
      employer = internship_offer_info.employer
      organisation = create(:organisation, employer: employer)
      tutor = create(:tutor, employer_id: employer.id)
      internship_offer = create(:weekly_internship_offer, employer: employer, organisation_id: organisation.id, internship_offer_info_id: internship_offer_info.id, tutor_id: tutor.id, max_candidates: 3, weeks: weeks)
      create(:weekly_internship_application, :approved, internship_offer: internship_offer, week: weeks(:week_2019_1))
      sign_in(internship_offer.employer)
      patch(dashboard_stepper_internship_offer_info_path(internship_offer_info.to_param),
            params: { 
              commit: "Modifier les informations de stage",
              internship_offer_info: {
                week_ids: week_ids,
                max_candidates: 2
              }
            }
      )
      follow_redirect!
      assert_select("#alert-text", text: "Les modifications sont enregistrées")
      assert_equal 2, internship_offer.reload.max_candidates
    end

    test 'PATCH #update as employer owning internship_offer ' \
        'updates internship_offer and fails due to too many accepted internships' do
      weeks = Week.all.first(4)
      week_ids = weeks.map(&:id)
      internship_offer_info = create(:weekly_internship_offer_info)
      employer = internship_offer_info.employer
      organisation = create(:organisation, employer: employer)
      tutor = create(:tutor, employer_id: employer.id)
      internship_offer = create(:weekly_internship_offer,
                                employer: employer,
                                organisation_id: organisation.id,
                                internship_offer_info_id: internship_offer_info.id,
                                tutor_id: tutor.id,
                                max_candidates: 3,
                                weeks: weeks)
      create(:weekly_internship_application, :approved, internship_offer: internship_offer, week: weeks.first)
      create(:weekly_internship_application, :approved, internship_offer: internship_offer, week: weeks.second)
      sign_in(internship_offer.employer)

      patch(dashboard_stepper_internship_offer_info_path(internship_offer_info.to_param),
            params: { 
              commit: "Modifier les informations de stage",
              internship_offer_info: {
                week_ids: week_ids,
                max_candidates: 1
              }
            }
      )
      error_message = "Impossible de réduire le " \
                      "nombre de places de cette offre de stage car vous avez déjà accepté " \
                      "plus de candidats que vous n'allez leur offrir de places."
      assert_response :bad_request
      assert_select("label.for-errors", text: error_message)
    end

    test 'PATCH #update as statistician owning internship_offer updates internship_offer' do
      internship_offer = create(:weekly_internship_offer)
      statistician = create(:statistician)
      internship_offer_info = create(:weekly_internship_offer_info, employer: statistician)
      organisation = create(:organisation, employer: statistician)
      tutor = create(:tutor, employer_id: statistician.id)
      internship_offer = create(:weekly_internship_offer,
                                employer: statistician,
                                organisation_id: organisation.id,
                                internship_offer_info_id: internship_offer_info.id,
                                tutor_id: tutor.id)
      # internship_offer.update(employer_id: statistician.id)
      new_title = 'new title'
      sign_in(statistician)
      patch(dashboard_stepper_internship_offer_info_path(internship_offer_info.to_param),
            params: { 
              commit: "Modifier les informations de stage",
              internship_offer_info: {
                title: new_title,
                week_ids: [weeks(:week_2019_1).id],
                new_daily_hours: {
                  'lundi' => ['10h', '12h']
                }
              } 
            }
          )
      assert_redirected_to(edit_dashboard_internship_offer_path(internship_offer, step: 2),
                          'redirection should point to updated offer')

      assert_equal(new_title,
                  internship_offer.reload.title,
                  'can\'t update internship_offer title')
      assert_equal ['10h', '12h'], internship_offer.reload.new_daily_hours['lundi']

    end
  end
end
