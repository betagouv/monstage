# frozen_string_literal: true

require 'test_helper'

module Dashboard::InternshipOffers
  class CreateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'POST #create (duplicate)  as visitor redirects to internship_offers' do
      post dashboard_internship_offers_path(params: {})
      assert_redirected_to user_session_path
    end

    test 'POST duplicate with no underlying objects as employer creates the post' do
      employer = create(:employer)
      internship_offer_ref = create(:weekly_internship_offer, employer: employer)
      sign_in(internship_offer_ref.employer)
      assert_difference('InternshipOffer.count', 1) do
        post(duplicate_dashboard_internship_offer_path(id:internship_offer_ref.id))
      end
      created_internship_offer = InternshipOffer.last
      assert_equal 2, InternshipOffer.count
      assert_equal 1, Organisation.count
      assert_equal 2, InternshipOfferInfo.count
      assert_equal 1, Tutor.count
      organisation = Organisation.take
      assert_equal organisation.id, created_internship_offer.organisation_id
      internship_offer_info = InternshipOfferInfo.order(created_at: :desc).first
      assert_equal internship_offer_info.id, created_internship_offer.internship_offer_info_id
      tutor = Tutor.take
      assert_equal tutor.id, created_internship_offer.tutor_id
      assert_equal internship_offer_ref.title, created_internship_offer.title
      assert_equal internship_offer_ref.employer_description, created_internship_offer.employer_description
      assert_equal internship_offer_ref.is_public, created_internship_offer.is_public
      assert_equal internship_offer_ref.siret, created_internship_offer.siret
      assert_equal internship_offer_ref.group_id, created_internship_offer.group_id
      assert_equal internship_offer_ref.max_candidates, created_internship_offer.max_candidates
      assert_equal internship_offer_ref.remaining_seats_count, created_internship_offer.remaining_seats_count
      assert_equal internship_offer_ref.employer_id, created_internship_offer.employer_id
      assert_equal internship_offer_ref.type, created_internship_offer.type
      assert_equal internship_offer_ref.school_id, created_internship_offer.school_id
      assert_equal internship_offer_ref.max_students_per_group, created_internship_offer.max_students_per_group
      assert_equal internship_offer_ref.max_candidates, created_internship_offer.max_candidates
      assert_equal internship_offer_ref.sector_id, created_internship_offer.sector_id
      assert_equal internship_offer_ref.weekly_hours, created_internship_offer.weekly_hours
      assert_equal internship_offer_ref.new_daily_hours, created_internship_offer.new_daily_hours
      assert_equal internship_offer_ref.daily_lunch_break, created_internship_offer.daily_lunch_break
      assert_equal internship_offer_ref.weekly_lunch_break, created_internship_offer.weekly_lunch_break
      assert_equal internship_offer_ref.street, created_internship_offer.street
      assert_equal internship_offer_ref.city, created_internship_offer.city
      assert_equal internship_offer_ref.zipcode, created_internship_offer.zipcode
      assert_equal internship_offer_ref.coordinates, created_internship_offer.coordinates
      assert_equal internship_offer_ref.week_ids, created_internship_offer.week_ids
      assert_equal internship_offer_ref.tutor_name, created_internship_offer.tutor_name
      assert_equal internship_offer_ref.tutor_phone, created_internship_offer.tutor_phone
      assert_equal internship_offer_ref.tutor_email, created_internship_offer.tutor_email
      assert_equal internship_offer_ref.tutor_role, created_internship_offer.tutor_role
      assert_redirected_to edit_dashboard_internship_offer_path(
        created_internship_offer,
        current_process: "offer_duplicate",
        step: 1
      )
    end

    test 'POST duplicate with underlying objects as employer creates the post' do
      employer = create(:employer)
      organisation = create(:organisation, employer: employer)
      internship_offer_info = create(:internship_offer_info)
      tutor = create(:tutor, employer_id: employer.id)
      internship_offer_ref = create(
        :weekly_internship_offer,
        employer: employer,
        organisation: organisation,
        internship_offer_info: internship_offer_info,
        tutor: tutor)
      sign_in(employer)
      assert_difference('InternshipOffer.count', 1) do
        post(duplicate_dashboard_internship_offer_path(id:internship_offer_ref.id))
      end
      assert_equal 2, InternshipOffer.count
      created_internship_offer = InternshipOffer.order(created_at: :desc).first
      assert_equal 1, Organisation.count
      assert_equal 2, InternshipOfferInfo.count
      assert_equal 1, Tutor.count
      organisation = Organisation.take
      assert_equal organisation.id, created_internship_offer.organisation_id
      internship_offer_info = InternshipOfferInfo.order(created_at: :desc).first
      assert_equal internship_offer_info.id, created_internship_offer.internship_offer_info_id
      tutor = Tutor.take
      assert_equal tutor.id, created_internship_offer.tutor_id
      assert_equal internship_offer_ref.title, created_internship_offer.title
      assert_equal internship_offer_ref.employer_description, created_internship_offer.employer_description
      assert_equal internship_offer_ref.is_public, created_internship_offer.is_public
      assert_equal internship_offer_ref.max_candidates, created_internship_offer.max_candidates
      assert_equal internship_offer_ref.remaining_seats_count, created_internship_offer.remaining_seats_count
      assert_equal internship_offer_ref.week_ids, created_internship_offer.week_ids
      assert_equal internship_offer_ref.employer_id, created_internship_offer.employer_id
      assert_equal internship_offer_ref.type, created_internship_offer.type
      assert_equal internship_offer_ref.school_id, created_internship_offer.school_id
      # .../....
      assert_redirected_to edit_dashboard_internship_offer_path(
        created_internship_offer,
        current_process: "offer_duplicate",
        step: 1
      )
    end

    test 'POST #create (duplicate) /InternshipOffers::WeeklyFramed as ministry statistican creates the post' do
      school = create(:school)
      employer = create(:ministry_statistician)
      weeks = [weeks(:week_2019_1)]
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
      assert_redirected_to internship_offer_path(created_internship_offer)
    end

    test 'POST #create as employer with missing params' do
      sign_in(create(:employer))
      post(dashboard_internship_offers_path, params: { internship_offer: {} })
      assert_response :bad_request
    end

     test 'POST #create as employer with invalid data, prefill form' do
      sign_in(create(:employer))
      post(dashboard_internship_offers_path, params: {
             internship_offer: {
               title: 'hello',
               is_public: false,
               group: 'Accenture',
               max_candidates: 2,
               max_students_per_group: 2
             }
           })

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
  end
end
