FactoryBot.define do
  factory :internship_offer_info do
    title { 'Stage de 3è' }
    description { 'Lorem ipsum dolor sit amet.' }
    sector { create(:sector) }
    employer { create(:employer) }
  end
end
