FactoryBot.define do
  factory :internship_application do
    student { create(:student) }
    internship_offer_week { create(:internship_offer_week) }
    motivation { 'Suis hyper motivé' }
  end
end
