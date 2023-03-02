# frozen_string_literal: true

FactoryBot.define do
  factory :internship_offer, aliases: %i[with_public_group_internship_offer] do
    sequence(:title) { |n| "Stage de 3è - #{n}" }
    description { 'Lorem ipsum dolor' }
    max_candidates { 1 }
    max_students_per_group { 1 }
    blocked_weeks_count { 0 }
    sector { create(:sector) }
    tutor_name { 'Eric Dubois' }
    tutor_phone { '0123456789' }
    tutor_email { 'eric@dubois.fr' }
    tutor_role { 'comptable' }
    is_public { true }
    group { create(:group, is_public: true) }
    employer { create(:employer) }  
    employer_description { 'on envoie du parpaing' }
    street { '1 rue du poulet' }
    zipcode { '75001' }
    city { 'Paris' }
    employer_name { 'Octo' }
    siret { '11122233300000' }

    trait :api_internship_offer do
      weeks { [Week.selectable_from_now_until_end_of_school_year.first] }
      employer { create(:user_operator) }
      permalink { 'https://google.fr' }
      description { 'Lorem ipsum dolor api' }
      sequence(:remote_id) { |n| n }
    end

    trait :weekly_internship_offer do
      coordinates { Coordinates.paris }
      weeks { [Week.selectable_from_now_until_end_of_school_year.first] }
      employer { create(:employer) }
      description { 'Lorem ipsum dolor weekly_internship_offer' }
      remaining_seats_count { max_candidates }
    end

    trait :last_year_weekly_internship_offer do
      coordinates { Coordinates.paris }
      weeks { [Week.of_previous_school_year.first] }
    end

    trait :weekly_internship_offer_by_statistician do
      coordinates { Coordinates.paris }
      weeks { [Week.selectable_from_now_until_end_of_school_year.first] }
    end

    trait :troisieme_generale_internship_offer do
      weeks { [Week.selectable_from_now_until_end_of_school_year.first] }
    end

    trait :discarded do
      discarded_at { Time.now }
    end

    trait :unpublished do
      after(:create) { |offer| offer.update(published_at: nil) }
    end

    trait :with_private_employer_group do
      is_public { false }
      group { create(:group, is_public: false) }
    end
    trait :with_public_group do
      is_public { true }
      group { create(:group, is_public: true) }
    end

    factory :api_internship_offer, traits: [:api_internship_offer],
                                   class: 'InternshipOffers::Api',
                                   parent: :weekly_internship_offer

    factory :weekly_internship_offer, traits: [:weekly_internship_offer],
                                      class: 'InternshipOffers::WeeklyFramed',
                                      parent: :internship_offer
    factory :last_year_weekly_internship_offer, traits: [:last_year_weekly_internship_offer],
                                                class: 'InternshipOffers::WeeklyFramed',
                                                parent: :internship_offer
    factory :weekly_internship_offer_by_statistician, traits: [:weekly_internship_offer_by_statistician],
                                      class: 'InternshipOffers::WeeklyFramed',
                                      parent: :internship_offer

  end
end
