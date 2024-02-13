# frozen_string_literal: true

FactoryBot.define do
  factory :internship_offer, aliases: %i[with_public_group_internship_offer] do
    # TODO use transient to set the distinction between weekly and api offers
    employer { create(:employer) }
    organisation { create(:organisation, employer: employer) }
    internship_offer_info { create(:internship_offer_info, employer: employer) }
    hosting_info { create(:hosting_info, employer: employer) }
    practical_info { create(:practical_info, employer: employer) }

    sequence(:title) { |n| "Stage de 3è - #{n}" }
    description { 'Lorem ipsum dolor' }
    contact_phone { '+330612345678' }
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
    internship_offer_area { create(:area, employer_id: employer.id, employer_type: 'User') }
    employer_description { 'on envoie du parpaing' }
    street { '1 rue du poulet' }
    zipcode { '75001' }
    city { 'Paris' }
    employer_name { 'Octo' }
    coordinates { Coordinates.paris }
    siret { '11122233300000' }
    aasm_state { 'published' }
    hidden_duplicate { false }
    handicap_accessible { false }
    daily_hours do
      {
        'lundi' => ['09:00', '17:00'],
        'mardi' => ['09:00', '17:00'],
        'mercredi' => ['09:00', '17:00'],
        'jeudi' => ['09:00', '17:00'],
        'vendredi' => ['09:00', '17:00']
      }
    end
    weekly_hours { [] }
    lunch_break { "12:00-13:00" }

    trait :drafted do
      aasm_state { :drafted }
    end

    trait :published do
      published_at { Time.now }
      aasm_state { 'published' }
    end

    trait :draft do
      published_at { nil }
      aasm_state { 'drafted' }
    end

    trait :unpublished do
      published_at { nil }
      aasm_state { 'unpublished' }
    end

    trait :weekly_internship_offer do
      weeks { [Week.selectable_from_now_until_end_of_school_year.first]}
      description { 'Lorem ipsum dolor weekly_internship_offer' }
      remaining_seats_count { max_candidates }
    end

    trait :api_internship_offer do
      weeks { [Week.selectable_from_now_until_end_of_school_year.first] }
      permalink { 'https://google.fr' }
      description { 'Lorem ipsum dolor api' }
      sequence(:remote_id) { |n| n }
      employer { create(:user_operator) }
      internship_offer_area { employer.current_area }
    end

    trait :last_year_weekly_internship_offer do
      weeks { [Week.of_previous_school_year.first] }
    end

    trait :weekly_internship_offer_by_statistician do
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

    #after(:create) do |internship_offer, params|
    #  create(:internship_offer_stats, internship_offer: internship_offer)
    #end

    factory :api_internship_offer, traits: [:api_internship_offer],
                                   class: 'InternshipOffers::Api',
                                   parent: :weekly_internship_offer

    factory :weekly_internship_offer, traits: [:weekly_internship_offer,  :published],
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
