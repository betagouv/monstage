require_relative '../support/coordinates'

FactoryBot.define do
  factory :school do
    name { 'Collègue evariste Gallois' }
    coordinates { Coordinates.paris }

    trait :at_paris do
      city { 'Paris' }
      department { 'Paris 75015' }
      coordinates { Coordinates.paris }
    end

    trait :at_bordeaux do
      city { 'bordeaux' }
      department { 'Gironde' }
      coordinates { Coordinates.bordeaux }
    end

    trait :with_school_manager do
      school_manager { build(:school_manager) }
    end
  end
end
