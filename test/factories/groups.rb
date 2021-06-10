FactoryBot.define do
  factory :group do
    is_public { false }
    name { 'MyString' }
    trait :public do
      is_public { true }
    end
    trait :pacte do
      is_pacte { true }
    end
    factory :public_group, traits: %i[public]
    factory :pacte_group, traits: %i[pacte]
  end
end
