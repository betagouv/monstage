FactoryBot.define do
  factory :organisation , aliases: [:public_organisation] do
    employer_name { "MyCorp" }
    employer_website { "https://website.com" }
    employer_description { "MyText" }
    employer
    street { '1 rue du poulet' }
    zipcode { '75001' }
    city { 'Paris' }
    coordinates { Coordinates.paris }
    is_public { true }
    group { create(:group, is_public: true) }

    trait :public do
      is_public { true }
      group { create(:group, is_public: true) }
    end
    trait :private do
      is_public { false }
      group { create(:group, is_public: false) }
    end
  end

  factory :private_organisation,
          class: 'Organisation',
          traits: [:private],
          parent: :organisation
end
