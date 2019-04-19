FactoryBot.define do
  factory :internship_application do
    student { create(:student) }
    internship_offer_week { create(:internship_offer_week) }
    motivation { 'Suis hyper motivé' }
  end

  trait :submitted do
    aasm_state { :submitted }
  end
  trait :approved do
    aasm_state { :approved }
    approved_at { 3.days.ago.to_date }
  end
  trait :rejected do
    aasm_state { :rejected }
    rejected_at { 2.days.ago.to_date }
  end

  trait :convention_signed do
    aasm_state { :convention_signed }
    convention_signed_at { 2.days.ago.to_date }
  end

end
