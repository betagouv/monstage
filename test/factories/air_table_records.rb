FactoryBot.define do
  factory :air_table_record do
    school_name { "MyText" }
    organisation_name { "MyText" }
    department_name { "MyText" }
    sector_name { "MyText" }
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
