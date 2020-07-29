FactoryBot.define do
  factory :organisation do
    name { "MyString" }
    street { "12 rue" }
    zipcode { "MyString" }
    city { "MyString" }
    is_public { true }
    website { "MyString" }
    description { "MyText" }
  end
end
