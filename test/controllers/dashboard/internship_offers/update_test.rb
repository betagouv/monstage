# frozen_string_literal: true
require 'test_helper'
module Dashboard::InternshipOffers
  class UpdateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    def next_weeks_ids
      current_week = Week.current
      res = (current_week.id..(current_week.id + 3)).to_a
    end

    def next_weeks_objects
      Week.where(id: next_weeks_ids)
    end

    test 'PATCH #update as visitor redirects to user_session_path' do
      travel_to(Date.new(2019,9,1)) do
        internship_offer = create(:weekly_internship_offer)
        patch(dashboard_internship_offer_path(internship_offer.to_param), params: {})
        assert_redirected_to user_session_path
      end
    end

    test 'PATCH #update as employer not owning internship_offer redirects to user_session_path' do
      internship_offer = create(:weekly_internship_offer)
      sign_in(create(:employer))
      patch(
        dashboard_internship_offer_path(internship_offer.to_param),
        params: { internship_offer: { title: 'tsee' } }
      )
      assert_redirected_to root_path
    end

    test 'PATCH #update with title as employer owning internship_offer updates internship_offer' \
         'even if dates are missing in the future since it is not published' do
      internship_offer = create(:weekly_internship_offer)
      new_title = 'new title'
      new_group = create(:group, is_public: false, name: 'woop')
      sign_in(internship_offer.employer)
      patch(dashboard_internship_offer_path(internship_offer.to_param),
            params: { internship_offer: {
              title: new_title,
              week_ids: [weeks(:week_2019_1).id],
              is_public: false,
              published_at: nil,
              group_id: new_group.id,
              daily_hours: {'lundi' => ['10h', '12h']}

            } })

      assert_redirected_to(dashboard_internship_offers_path(origine: 'dashboard'))

      assert_equal(new_title,
                   internship_offer.reload.title,
                   'can\'t update internship_offer title')
      assert_equal ['10h', '12h'], internship_offer.reload.daily_hours['lundi']
    end


    test 'PATCH #update sucessfully with title as employer owning internship_offer updates internship_offer' do
      internship_offer = create(:weekly_internship_offer)
      new_title = 'new title'
      new_group = create(:group, is_public: false, name: 'woop')
      sign_in(internship_offer.employer)
      patch(dashboard_internship_offer_path(internship_offer.to_param),
            params: {
              internship_offer: {
                title: new_title,
                week_ids: Week.selectable_from_now_until_end_of_school_year.map(&:id),
                is_public: false,
                group_id: new_group.id,
                daily_hours: {'lundi' => ['10h', '12h']}
              }
            })

      assert_redirected_to(dashboard_internship_offers_path(origine: 'dashboard'))

      assert_equal(new_title,
                   internship_offer.reload.title,
                   'can\'t update internship_offer title')
      assert_equal ['10h', '12h'], internship_offer.reload.daily_hours['lundi']

    end

    test 'PATCH #update as employer owning internship_offer ' \
         'updates internship_offer' do
      travel_to(Date.new(2019,9,1)) do
        weeks = Week.all.first(40).last(3)
        week_ids = weeks.map(&:id)
        internship_offer = create(:weekly_internship_offer, max_candidates: 3, weeks: weeks)
        create(:weekly_internship_application,
               :approved,
               internship_offer: internship_offer,
               week: weeks[2]
        )
        sign_in(internship_offer.employer)
        patch(dashboard_internship_offer_path(internship_offer.to_param),
              params: { internship_offer: {
                week_ids: week_ids,
                max_candidates: 2
              } })
        follow_redirect!
        
        assert_select("#alert-text", text: "Votre annonce a bien été modifiée")
        assert_equal 2, internship_offer.reload.max_candidates
      end
    end

    test 'PATCH #update as employer owning internship_offer ' \
         'updates internship_offer and fails due to too many accepted internships' do
      travel_to(Date.new(2019,9,1)) do
        current_week = Week.current
        week_ids = (current_week.id..(current_week.id + 4)).to_a
        weeks = Week.where(id: week_ids)
        internship_offer = create(
          :weekly_internship_offer, max_candidates: 3,
          weeks: weeks
        )
        create(:weekly_internship_application,
               :approved,
               internship_offer: internship_offer,
               week: weeks.first)
        create(:weekly_internship_application,
               :approved,
               internship_offer: internship_offer,
               week: weeks.second)
        sign_in(internship_offer.employer)

        patch(dashboard_internship_offer_path(internship_offer.to_param),
              params: { internship_offer: {
                week_ids: week_ids,
                max_candidates: 1
              } })
        error_message = "Nbr. max de candidats accueillis sur l'année : Impossible de réduire le " \
                        "nombre de places de cette offre de stage car vous avez déjà accepté " \
                        "plus de candidats que vous n'allez leur offrir de places."
        assert_response :bad_request
        assert_select(".fr-alert.fr-alert--error", text: error_message)
      end
    end

    test 'PATCH #update as statistician owning internship_offer updates internship_offer' do
      weeks= Week.selectable_from_now_until_end_of_school_year + [Week.last]
      internship_offer = create(:weekly_internship_offer, weeks: weeks)
      statistician = create(:statistician)
      internship_offer.update(employer_id: statistician.id)
      new_title = 'new title'
      new_group = create(:group, is_public: false, name: 'woop')
      sign_in(statistician)
      patch(dashboard_internship_offer_path(internship_offer.to_param),
            params: { internship_offer: {
              title: new_title,
              week_ids: [Week.current.id.to_i + 52],
              is_public: false,
              group_id: new_group.id,
              daily_hours: {'lundi' => ['10h', '12h']}

            } })
      assert_redirected_to(dashboard_internship_offers_path(origine: 'dashboard'),
                           'redirection should point to updated offer')

      assert_equal(new_title,
                   internship_offer.reload.title,
                   'can\'t update internship_offer title')
      assert_equal ['10h', '12h'], internship_offer.reload.daily_hours['lundi']

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

    test 'PATCH #update as employer owning internship_offer can unpublish an offer without enough remaining weeks' do
      employer = create(:employer)
      # publish in september to host 30 students
      travel_to(Date.new(2023,9,1)) do
        internship_offer = create(:weekly_internship_offer, employer: employer, max_candidates: 30, max_students_per_group: 1, week_ids: Week.selectable_from_now_until_end_of_school_year.map(&:id))
      end
      sign_in(employer)
      # try to unpublish in june
      travel_to(Date.new(2024,6,1)) do
        internship_offer = InternshipOffer.last
        assert_changes -> { internship_offer.reload.published_at },
                       from: internship_offer.published_at,
                       to: nil do
          patch(dashboard_internship_offer_path(internship_offer.to_param),
                params: { internship_offer: { aasm_state: 'unpublished' } })
        end
      end
    end

    test 'PATCH #update as employer is able to remove school' do
      # travel_to(Date.new(2019,9,1)) do
        school = create(:school)
        internship_offer = create(:weekly_internship_offer, school: school)
        sign_in(internship_offer.employer)
        assert_changes -> { internship_offer.reload.school },
                      from: school,
                      to: nil do
          patch(dashboard_internship_offer_path(internship_offer.to_param),
                params: { internship_offer: { school_id: nil } })
        end
      # end
    end

    test 'PATCH #republish as employer with missing seats' do
      travel_to(Date.new(2019,9,1)) do
        employer = create(:employer)
        internship_offer = create(:weekly_internship_offer,
                                  weeks: next_weeks_objects,
                                  employer: employer,
                                  max_candidates: 1,
                                  max_students_per_group: 1)
        internship_application = create(:weekly_internship_application,
                                        :submitted,
                                        internship_offer: internship_offer)

        internship_application.employer_validate!
        internship_application.approve!

        assert_equal 0, internship_offer.reload.remaining_seats_count
        assert internship_offer.need_to_be_updated?

        sign_in(employer)
        patch republish_dashboard_internship_offer_path(
          internship_offer.to_param
        )
        follow_redirect!
        assert_select(
          "span#alert-text",
          text: "Votre annonce n'est pas encore republiée, car il faut ajouter des places de stage")
        refute internship_offer.reload.published?
      end
    end

    test 'PATCH #republish as employer with missing weeks' do
      travel_to Date.new(2019,10,1) do
        employer = create(:employer)
        internship_offer = create(:weekly_internship_offer,
                                  employer: employer,
                                  weeks: [Week.current])
        assert internship_offer.need_to_be_updated?

        sign_in(employer)
        patch republish_dashboard_internship_offer_path(
          internship_offer.to_param
        )
        follow_redirect!
        assert_select(
          "[data-controller='flash'] span#alert-text",
          text: "Votre annonce n'est pas encore republiée, car il faut ajouter des semaines de stage"
        )
        refute internship_offer.reload.published?
      end
    end

    test 'PATCH #republish as employer with missing weeks and seats' do
      weeks = []
      travel_to Date.new(2019, 9, 1) do
        weeks = Week.selectable_from_now_until_end_of_school_year.first(1)
      end
      travel_to Date.new(2019, 10, 1) do
        employer = create(:employer)
        internship_offer = create(:weekly_internship_offer,
                                  employer: employer,
                                  max_candidates: 1,
                                  weeks: weeks,
                                  max_students_per_group: 1)
        internship_application = create(:weekly_internship_application,
                                        :submitted,
                                        internship_offer: internship_offer)
        internship_application.employer_validate!
        internship_application.approve!
        assert_equal 0, internship_offer.reload.remaining_seats_count
        refute internship_offer.published? #self.reload.published_at.nil?

        sign_in(employer)
        patch republish_dashboard_internship_offer_path(
          internship_offer.to_param
        )
        follow_redirect!
        assert_select(
          "span#alert-text",
          text: "Votre annonce n'est pas encore republiée, car il faut ajouter des places et des semaines de stage"
        )
        refute internship_offer.reload.published?
      end
    end

    test 'PATCH as employer while removing weeks where internship_applications were formerly created' do
      travel_to Date.new(2019, 10, 1) do
        weeks = Week.selectable_from_now_until_end_of_school_year.first(2)
        employer = create(:employer)
        internship_offer = create(:weekly_internship_offer,
                                  employer: employer,
                                  max_candidates: 1,
                                  weeks: weeks,
                                  max_students_per_group: 1)
        internship_application = create(:weekly_internship_application,
                                        :submitted,
                                        week: weeks.first,
                                        internship_offer: internship_offer)
        sign_in(employer)
        patch dashboard_internship_offer_path(internship_offer.to_param),
              params: { internship_offer: internship_offer.attributes.merge!({week_ids:[weeks.second.id]}) }
        refute internship_application.canceled_by_employer?
        assert internship_application.reload.canceled_by_employer?
      end
    end

    test 'PATCH to unpublish offers with daily cron/rake job ' do
      employer = create(:employer)
      internship_offer = nil
      travel_to Date.new(2019, 10, 1) do
        weeks = Week.selectable_from_now_until_end_of_school_year.first(2)
        internship_offer = create(:weekly_internship_offer,
                                  employer: employer,
                                  max_candidates: 1,
                                  weeks: weeks,
                                  max_students_per_group: 1)
      end
      refute_nil internship_offer.published_at
      assert_equal 1, InternshipOffer.published.count
      travel_to Date.new(2020, 3, 2) do
        assert internship_offer.last_date < Time.now.utc
        assert_changes -> {InternshipOffer.published.count},
                       from: 1,
                       to: 0 do
          Monstage::Application.load_tasks
          Rake::Task['internship_offers_unpublish'].invoke
        end
      end
      assert_equal 'need_to_be_updated', internship_offer.reload.aasm_state
    end
  end
end  
