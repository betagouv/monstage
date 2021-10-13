# frozen_string_literal: true

require 'test_helper'

module Dashboard::InternshipOffers
  class CreateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'POST #create (duplicate)  as visitor redirects to internship_offers' do
      post dashboard_internship_offers_path(params: {})
      assert_redirected_to user_session_path
    end

    test 'POST #create (duplicate) /InternshipOffers::WeeklyFramed as employer creates the post' do
      school = create(:school)
      employer = create(:employer)
      tutor = create(:tutor)
      weeks = [weeks(:week_2019_1)]
      internship_offer = build(:weekly_internship_offer, employer: employer, tutor: tutor)
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
                      'tutor_attributes' => internship_offer.tutor.attributes)

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
      assert_redirected_to internship_offer_path(created_internship_offer)
    end

    test 'POST #create (duplicate) /InternshipOffers::FreeDate as employer creates the post' do
      school = create(:school)
      employer = create(:employer)
      internship_offer = build(:free_date_internship_offer, employer: employer)
      sign_in(internship_offer.employer)
      params = internship_offer
               .attributes
               .merge('type' => InternshipOffers::FreeDate.name,
                      'coordinates' => { latitude: 1, longitude: 1 },
                      'school_id' => school.id,
                      'description_rich_text' => '<div>description</div>',
                      'employer_description_rich_text' => '<div>hop+employer_description</div>',
                      'employer_id' => internship_offer.employer_id,
                      'tutor_attributes' => internship_offer.tutor.attributes)

      assert_difference('InternshipOffer.count', 1) do
        post(dashboard_internship_offers_path, params: { internship_offer: params })
      end
      created_internship_offer = InternshipOffer.last
      assert_equal InternshipOffers::FreeDate.name, created_internship_offer.type
      assert_equal employer, created_internship_offer.employer
      assert_equal school, created_internship_offer.school
      assert_equal 'troisieme_segpa', created_internship_offer.school_track
      assert_equal params['max_candidates'], created_internship_offer.max_candidates
      assert_redirected_to internship_offer_path(created_internship_offer)
    end


    test 'POST #create as employer with missing params' do
      sign_in(create(:employer))
      post(dashboard_internship_offers_path, params: { internship_offer: {} })
      assert_response :bad_request
    end

    test 'POST #create as employer with invalid data, prefill form' do
      sign_in(create(:employer))
      post(dashboard_internship_offers_path,
           params: {
             internship_offer: {
               title: 'hello',
               is_public: false,
               group: 'Accenture',
               max_candidates: 2
             }
           }
      )
      assert_select 'li label[for=internship_offer_coordinates]',
                    text: 'Veuillez saisir et sélectionner une adresse avec ' \
                          "l'outil de complétion automatique"
      assert_select 'li label[for=internship_offer_zipcode]',
                    text: "Veuillez renseigner le code postal de l'employeur"
      assert_select 'li label[for=internship_offer_city]',
                    text: "Veuillez renseigner la ville l'employeur"

      assert_select '#internship_offer_is_public_true[checked]',
                    count: 0 # "ensure user select kind of group"
      assert_select '#internship_offer_is_public_false[checked]',
                    count: 1 # "ensure user select kind of group"
      assert_select '.form-group-select-group.d-none', count: 0

      assert_select '#internship_type_true[checked]', count: 0
      assert_select '#internship_type_false[checked]', count: 1
      assert_select '.form-group-select-max-candidates.d-none', count: 0
    end

    test 'internship creation sends an email to the tutor' do
      assert_emails 1 do
        create(:troisieme_generale_internship_offer)
      end
    end
  end
end
