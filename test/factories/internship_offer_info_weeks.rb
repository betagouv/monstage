FactoryBot.define do
  factory :internship_offer_info_week do
    Week.selectable_from_now_until_end_of_school_year.first(2)
  end
end
