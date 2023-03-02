FactoryBot.define do
  factory :email_whitelist do
  end

  factory :statistician_email_whitelist,
          class: EmailWhitelists::PrefectureStatistician,
          parent: :email_whitelist do
    email { "departemental_statistician_#{rand(1..10_000)}@ms3e.fr" }
    zipcode { 60 }
  end

  factory :education_statistician_email_whitelist,
          class: EmailWhitelists::EducationStatistician,
          parent: :email_whitelist do
    email { "education_statistician_#{rand(1..10_000)}@ms3e.fr" }
    zipcode { 60 }
  end

  factory :ministry_statistician_email_whitelist,
          class: EmailWhitelists::Ministry,
          parent: :email_whitelist do
    email { "ministry_statistician_#{rand(1..10_000)}@ms3e.fr" }
    groups { [create(:group, is_public: true), create(:group, is_public: true)] }
  end
end
