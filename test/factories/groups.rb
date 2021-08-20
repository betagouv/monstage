FactoryBot.define do
  factory :group do
    is_public { false }
    name { 'MyString' }
    is_pacte { false }

    trait :public do
      is_public { true }
      is_pacte { false }
    end
    trait :private do
      is_public { false }
    end
    trait :pacte do
      is_public { false }
      is_pacte { true }
    end

    factory :public_group, traits: %i[public]
    factory :private_group, traits: %i[private]
    factory :pacte_group, traits: %i[pacte]
  end
end
