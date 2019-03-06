FactoryBot.define do
  factory :user do
    first_name { 'Jean Claude' }
    last_name { 'Dus' }

    factory :student do
      type { 'Student' }
    end

    trait :lafami do
      # school { }
    end
  end
end
