# frozen_string_literal: true

require_relative '../support/coordinates'

FactoryBot.define do
  factory :school do
    name { 'Collège evariste Gallois' }
    coordinates { Coordinates.paris }
    city { 'Paris' }
    zipcode { '75015' }
    code_uai { '0440311Z' }
    trait :at_paris do
      city { 'Paris' }
      name { 'Parisian school' }
      department { 'Paris 75015' }
      coordinates { Coordinates.paris }
    end

    trait :at_bordeaux do
      city { 'bordeaux' }
      name { 'bordeaux school' }
      department { 'Gironde' }
      coordinates { Coordinates.bordeaux }
      zipcode { '30072' }
    end

    trait :with_school_manager do
      school_manager { build(:school_manager) }
    end

    trait :with_weeks do
      weeks { Week.selectable_on_school_year[0..1] }
    end

    trait :with_troisieme_generale do
      class_rooms { [build(:class_room, :troisieme_generale)] }
    end

    trait :with_troisieme_segpa do
      class_rooms { [build(:class_room, :troisieme_segpa)] }
    end

    trait :with_agreement_presets do
      internship_agreement_preset { build(:internship_agreement_preset,
                                           school_delegation_to_sign_delivered_at: 2.years.ago)}
    end

    trait :with_agreement_presets_missing_date do
      internship_agreement_preset { build(:internship_agreement_preset,
                                           school_delegation_to_sign_delivered_at: nil)}
      weeks { [Week.selectable_from_now_until_end_of_school_year.first] }
    end

    factory :school_with_troisieme_segpa_class_room do
      after(:create) do |school|
        create(:class_room, school: school, school_track: 'troisieme_segpa')
      end
    end

    factory :school_with_troisieme_generale_class_room do
      after(:create) do |school|
        create(:class_room, school: school, school_track: 'troisieme_generale')
      end
    end
  end

  factory :api_school, class: Api::School do
    name { 'Collège evariste Gallois' }
    city { 'Paris' }
    coordinates { Coordinates.paris }
    zipcode { '75015' }
  end
end
