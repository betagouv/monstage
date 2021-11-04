FactoryBot.define do
  factory :group do
    is_public { false }
    name { 'MyString' }
    is_paqte { false }

    trait :public do
      is_public { true }
      is_paqte { false }
    end
    trait :private do
      is_public { false }
    end
    trait :paqte do
      is_public { false }
      is_paqte { true }
    end

    factory :public_group, traits: %i[public]
    factory :private_group, traits: %i[private]
    factory :paqte_group, traits: %i[paqte]
  end
end
