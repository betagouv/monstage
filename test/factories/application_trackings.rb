FactoryBot.define do
  factory :application_tracking do
    internship_offer { create(:api_internship_offer)}
    student { create(:student) }
    operator { create(:user_operator) }
    application_submitted_at { 3.days.ago }
    application_approved_at { 2.days.ago }
    visitor_generated_id { DateTime.now.to_i.to_s }
    remote_status { 5 }

    trait :submitted do
      remote_status { 5 }
    end

    trait :approved do
      remote_status { 10 }
    end
  end
end
