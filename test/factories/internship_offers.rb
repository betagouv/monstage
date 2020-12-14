# frozen_string_literal: true

FactoryBot.define do
  factory :internship_offer do
    sequence(:title) { |n| "Stage de 3è - #{n}" }
    max_candidates { 1 }
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

    trait :api_internship_offer do
      weeks { [Week.selectable_from_now_until_end_of_school_year.first] }
      employer { create(:user_operator) }
      school_track { :troisieme_generale }
      permalink { 'https://google.fr' }
      description { 'Lorem ipsum dolor' }
      sequence(:remote_id) { |n| n }
    end

    trait :weekly_internship_offer do
      weeks { [Week.selectable_from_now_until_end_of_school_year.first] }
      employer { create(:employer) }
      school_track { :troisieme_generale }
      description { 'Lorem ipsum dolor' }
    end

    trait :free_date_internship_offer do
      employer { create(:employer) }
      school_track { :bac_pro }
      description { 'Lorem ipsum dolor' }
    end

    trait :discarded do
      discarded_at { Time.now }
    end

    factory :api_internship_offer, traits: [:api_internship_offer],
                                   class: 'InternshipOffers::Api'
    factory :weekly_internship_offer, traits: [:weekly_internship_offer],
                                      class: 'InternshipOffers::WeeklyFramed',
                                      parent: :internship_offer
    factory :free_date_internship_offer, traits: [:free_date_internship_offer],
                                         class: 'InternshipOffers::FreeDate',
                                         parent: :internship_offer
  end
end
