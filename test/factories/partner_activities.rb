FactoryBot.define do
  factory :partner_activity do
    student_id { create(:student).id }
    operator_id  { create(:operator).id }
    internship_offer { nil }
    account_created { nil }
    internship_offer_viewed { nil }
    internship_application_sent { nil }
    internship_application_accepted { nil }
  end
end
