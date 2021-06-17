FactoryBot.define do
  factory :group do
    is_public { false }
    name { 'MyString' }
    is_pacte { false }

    trait :public do
      is_public { true }
      is_pacte { false }
    end

    trait :pacte do
      is_public { false }
      is_pacte { true }
    end

    factory :public_group, traits: %i[public]
    factory :pacte_group, traits: %i[pacte]
  end
end
