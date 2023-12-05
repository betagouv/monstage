FactoryBot.define do
  factory :url_shrinker do
    original_url { Rails.application.routes.url_helpers.mentions_legales_url  **Rails.configuration.action_mailer.default_url_options}
    url_token { "MyString" }
    user { create(:student) }
  end
end
