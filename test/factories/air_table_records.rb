FactoryBot.define do
  factory :air_table_record do
    week { Week.selectable_from_now_until_end_of_school_year.first }
    operator { create(:operator) }
    department_name { "MyText" }
    is_public { false }
    nb_spot_available { 1 }
    nb_spot_used { 1 }
    nb_spot_male { 1 }
    nb_spot_female { 1 }
    school_track { "MyText" }
    internship_offer_type { "MyText" }
    comment { "MyText" }
  end
end
