FactoryBot.define do
  factory :identity do
    
    first_name { FFaker::NameFR.first_name  }
    last_name { FFaker::NameFR.last_name }
    gender { 'm' }
    birth_date { 14.years.ago }
    school { create(:school, :with_school_manager) }
    token { 'abcdef' }
    
    trait :male do
      gender { 'm' }
    end
    
    trait :female do
      gender { 'f' }
    end

    trait :not_precised do
      gender { 'np' }
    end

    factory :identity_student_with_class_room_3e do
      class_room { create(:class_room, school: school) }
    end
  
  end
end
