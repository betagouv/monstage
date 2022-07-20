# frozen_string_literal: true

FactoryBot.define do
  factory :internship_offer, aliases: %i[with_public_group_internship_offer] do
    sequence(:title) { |n| "Stage de 3è - #{n}" }
    max_candidates { 1 }
    max_students_per_group { 1 }
    blocked_weeks_count { 0 }
    sector { create(:sector) }
    tutor_name { 'Eric Dubois' }
    tutor_phone { '0123456789' }
    tutor_email { 'eric@dubois.fr' }
    is_public { true }
    group { create(:group, is_public: true) }
    employer_description { 'on envoie du parpaing' }
    street { '1 rue du poulet' }
    zipcode { '75001' }
    city { 'Paris' }
    employer_name { 'Octo' }
    coordinates { Coordinates.paris }
    siret { '11122233300000' }

    trait :api_internship_offer do
      weeks { [Week.selectable_from_now_until_end_of_school_year.first] }
      employer { create(:user_operator) }
      school_track { :troisieme_generale } # default parameter
      permalink { 'https://google.fr' }
      description { 'Lorem ipsum dolor api' }
      sequence(:remote_id) { |n| n }
    end

    trait :weekly_internship_offer do
      school_track { :troisieme_generale }
      weeks { [Week.selectable_from_now_until_end_of_school_year.first] }
      employer { create(:employer) }
      description { 'Lorem ipsum dolor weekly_internship_offer' }
    end

    trait :last_year_weekly_internship_offer do
      school_track { :troisieme_generale }
      weeks { [Week.of_previous_school_year.first] }
      employer { create(:employer) }
      description { 'Lorem ipsum dolor weekly_internship_offer' }
    end

    trait :weekly_internship_offer_by_statistician do
      school_track { :troisieme_generale }
      weeks { [Week.selectable_from_now_until_end_of_school_year.first] }
      employer { create(:employer) }
      description { 'Lorem ipsum dolor weekly_internship_offer' }
    end

    trait :troisieme_generale_internship_offer do
      weeks { [Week.selectable_from_now_until_end_of_school_year.first] }
      school_track { :troisieme_generale }
      employer { create(:employer) }
      description { 'Lorem ipsum dolor troisieme_generale_internship_offer' }
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
