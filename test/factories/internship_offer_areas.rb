FactoryBot.define do
  factory :internship_offer_area do
    employer { create(:employer) }
    name { "MySpace" }
  end
end
