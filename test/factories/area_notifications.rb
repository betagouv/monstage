FactoryBot.define do
  factory :area_notification do
    user_id { nil }
    internship_offer_area { nil }
    notify { true }
  end
end
