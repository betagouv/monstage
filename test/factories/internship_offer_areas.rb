FactoryBot.define do
  factory :internship_offer_area do
    employer_type {'User'}
  end

  trait :weekly do
    sequence(:name) { |n| "Bordeaux-#{n}" }
    employer_id { create(:employer).id }
  end

  trait :api do
    sequence(:name) { |n| "Lille-#{n}" }
    employer_id { create(:user_operator).id }
  end

  factory :weekly_internship_offer_area, traits: [:weekly],
                                         class: 'InternshipOfferArea',
                                         aliases: [:area],
                                         parent: :internship_offer_area
  factory :api_internship_offer_area, traits: [:api],
                                      aliases: [:api_area],
                                      class: 'InternshipOfferArea',
                                      parent: :internship_offer_area
end
