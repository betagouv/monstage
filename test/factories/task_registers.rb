FactoryBot.define do
  factory :task_register do
    task_name { "MyString" }
    played_at { Time.zone.now }
  end
  factory :development_task_register, parent: :task_register do
    used_environment { "development" }
  end
  factory :staging_task_register, parent: :task_register do
    used_environment { "staging" }
  end
  factory :review_task_register, parent: :task_register do
    used_environment { "review" }
  end
  factory :production_task_register, parent: :task_register do
    used_environment { "production" }
  end
end
