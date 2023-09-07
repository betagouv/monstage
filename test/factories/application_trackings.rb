FactoryBot.define do
  factory :application_tracking, class: "Api::ApplicationTracking" do
    internship_offer { create(:api_internship_offer)}
    student { create(:student) }
    user_operator { create(:user_operator) }
    application_submitted_at {  }
    application_approved_at {  }
    ms3e_student_id {  }
    remote_status { 5 }

    trait :submitted do
      remote_status { 5 }
      application_submitted_at { 3.days.ago }
    end

    trait :approved do
      remote_status { 10 }
      application_approved_at { 2.days.ago }
    end
  end
end
