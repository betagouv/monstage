FactoryBot.define do
  factory :url_shrinker do
    original_url { "MyString" }
    url_token { "MyString" }
    user { nil }
  end
end
