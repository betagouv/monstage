FactoryBot.define do
  factory :organisation do
    association :creator, factory: :employer
    employer_name { "MyCorp" }
    employer_website { "https://website.com" }
    employer_description { "MyText" }
    street { '1 rue du poulet' }
    zipcode { '75001' }
    city { 'Paris' }
    coordinates { Coordinates.paris }
    is_public { true }
    group { create(:group, is_public: true) }
  end
end
