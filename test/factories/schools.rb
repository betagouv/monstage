require_relative '../support/coordinates'

FactoryBot.define do
  factory :school do
    name { 'Collègue evariste Gallois' }

    trait :at_paris do
      city { 'Paris' }
      departement_name { 'Paris 75015' }
      coordinates { Coordinates.paris }
    end

    trait :at_bordeaux do
      city { 'bordeaux' }
      departement_name { 'Gironde' }
      coordinates { Coordinates.bordeaux }
    end
  end
end
