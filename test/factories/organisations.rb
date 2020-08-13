FactoryBot.define do
  factory :organisation do
    name { "MyCorp" }
    street { '1 rue du poulet' }
    zipcode { '75001' }
    city { 'Paris' }
    coordinates { Coordinates.paris }
    is_public { true }
    website { "https://website.com" }
    description { "MyText" }
    group { create(:group, is_public: true) }
  end
end
