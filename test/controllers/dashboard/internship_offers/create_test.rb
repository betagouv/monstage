# frozen_string_literal: true

require 'test_helper'

module Dashboard::InternshipOffers
  class CreateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    def next_week
      @next_week ||= Week.selectable_from_now_until_end_of_school_year.first
    end

    test 'POST #create (duplicate)  as visitor redirects to internship_offers' do
      post dashboard_internship_offers_path(params: {})
      assert_redirected_to user_session_path
    end

    test 'POST #create (duplicate) /InternshipOffers::WeeklyFramed as employer creates the post' do
      travel_to(Date.new(2019, 3, 1)) do
        school = create(:school)
        employer = create(:employer)
        weeks = [next_week]
        internship_offer = build(:weekly_internship_offer, employer: employer)
        sign_in(internship_offer.employer)
        params = internship_offer
                  .attributes
                  .merge('type' => InternshipOffers::WeeklyFramed.name,
                         'week_ids' => weeks.map(&:id),
                         'coordinates' => { latitude: 1, longitude: 1 },
                         'school_id' => school.id,
                         'description_rich_text' => '<div>description</div>',
                         'employer_description_rich_text' => '<div>hop+employer_description</div>',
                         'employer_id' => internship_offer.employer_id,
                         'employer_type' => 'Users::Employer')
        assert_difference('InternshipOffer.count', 1) do
          post(dashboard_internship_offers_path,
          params: { internship_offer: params })
        end
        created_internship_offer = InternshipOffer.last
        assert_equal InternshipOffers::WeeklyFramed.name, created_internship_offer.type
        assert_equal employer, created_internship_offer.employer
        assert_equal school, created_internship_offer.school
        assert_equal weeks.map(&:id), created_internship_offer.week_ids
        assert_equal weeks.size, created_internship_offer.internship_offer_weeks_count
        assert_equal params['max_candidates'], created_internship_offer.max_candidates
        assert_equal params['max_candidates'], created_internship_offer.remaining_seats_count
        assert_redirected_to internship_offer_path(created_internship_offer, stepper: true)
      end
    end

    test 'POST #create (duplicate) /InternshipOffers::WeeklyFramed as ministry statistican creates the post' do
      travel_to(Date.new(2020, 9, 1)) do
        school = create(:school)
        employer = create(:ministry_statistician)
        weeks = Week.selectable_from_now_until_end_of_school_year
        internship_offer = build(:weekly_internship_offer, employer: employer)
        sign_in(internship_offer.employer)
        params = internship_offer
                  .attributes
                  .merge('type' => InternshipOffers::WeeklyFramed.name,
                          'group' => employer.ministries.first,
                          'week_ids' => weeks.map(&:id),
                          'coordinates' => { latitude: 1, longitude: 1 },
                          'school_id' => school.id,
                          'description_rich_text' => '<div>description</div>',
                          'employer_description_rich_text' => '<div>hop+employer_description</div>',
                          'employer_type' => 'Users::MinistryStatistician')

        assert_difference('InternshipOffer.count', 1) do
          post(dashboard_internship_offers_path, params: { internship_offer: params })
        end
        created_internship_offer = InternshipOffer.last
        assert_equal InternshipOffers::WeeklyFramed.name, created_internship_offer.type
        assert_equal employer, created_internship_offer.employer
        assert_equal school, created_internship_offer.school
        assert_equal weeks.map(&:id), created_internship_offer.week_ids
        assert_equal weeks.size, created_internship_offer.internship_offer_weeks_count
        assert_equal params['max_candidates'], created_internship_offer.max_candidates
        assert_redirected_to internship_offer_path(created_internship_offer, stepper: true)
      end
    end

    test 'POST #create as employer with invalid data, prefill form' do
      sign_in(create(:employer))
      post(dashboard_internship_offers_path, params: {
             internship_offer: {
               title: 'hello',
               is_public: false,
               group: 'Accenture',
               max_candidates: 2,
             }
           })
      assert_select('.fr-alert.fr-alert--error', count: 2)
      assert_select('.fr-alert.fr-alert--error strong', html: /Code postal/)
      assert_select('.fr-alert.fr-alert--error strong', html: /Description/)
      assert_select('.fr-alert.fr-alert--error strong', html: /Secteur/)
      assert_select('.fr-alert.fr-alert--error strong', html: /Coordonnées GPS/)
      assert_select('.fr-alert.fr-alert--error strong', html: /Adresse du lieu de stage/)

      assert_select('.fr-alert.fr-alert--error', html: /Veuillez renseigner le code postal de l'employeur/)
      assert_select('.fr-alert.fr-alert--error', html: /Veuillez saisir une description pour l'offre de stage/)
      assert_select('.fr-alert.fr-alert--error', html: /Veuillez saisir le nom de l'employeur/)
      assert_select('.fr-alert.fr-alert--error', html: /Veuillez renseigner la rue ou compléments d'adresse de l'offre de stage/)
      assert_select('.fr-alert.fr-alert--error', html: /Veuillez renseigner la ville l'employeur/)

      assert_select '#internship_offer_organisation_attributes_is_public_true[checked]',
                    count: 0 # "ensure user select kind of group"
      assert_select '#internship_offer_organisation_attributes_is_public_false[checked]',
                    count: 0 # "ensure user select kind of group"
      assert_select '.form-group-select-group.d-none', count: 0

      assert_select '#internship_type_true[checked]', count: 1
      assert_select '#internship_type_false[checked]', count: 0
      assert_select '.form-group-select-max-candidates.d-none', count: 0
    end
  end
end
