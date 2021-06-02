FactoryBot.define do
  factory :email_whitelist do
  end
  factory :statistician_email_whitelist,
          class: EmailWhitelists::Statistician,
          parent: :email_whitelist do
    email { "departemental_statistician#{rand(1..10_000)}@ms3e.fr" }
  end
end
