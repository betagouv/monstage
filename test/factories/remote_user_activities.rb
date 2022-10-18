FactoryBot.define do
  factory :remote_user_activity do
    student_id { create(:student).id }
    operator_id  { create(:operator).id }
    internship_offer { nil }
    account_created_at { Time.zone.now - 2.days}
    internship_offer_viewed_at { Time.zone.now - 1.day}
    internship_application_sent_at { Time.zone.now - 6.hours}
    internship_application_accepted_at { Time.zone.now - 5.minutes}
  end
end
