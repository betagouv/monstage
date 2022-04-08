FactoryBot.define do
  factory :identity do
    
    first_name { 'Rick' }
    last_name { 'Roll' }
    gender { 'm' }
    birth_date { 14.years.ago }
    school { create(:school, :with_school_manager) }
    
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
      class_room { create(:class_room, school: school, school_track: 'troisieme_generale') }
    end
  
  end
end
