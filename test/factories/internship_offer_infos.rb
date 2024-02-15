FactoryBot.define do
  factory :internship_offer_info do
    title { "Stage de 3è" }
    description { 'Lorem ipsum dolor sit amet.' }
    description_rich_text { '<p>Lorem ipsum dolor sit amet.<p>' }
    sector { create(:sector) }
    employer { create(:employer) }
  end
end
