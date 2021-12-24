# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { 'Jean Claude' }
    last_name { 'Dus' }
    sequence(:email) { |n| "jean#{n}-claude@dus.fr" }
    password { 'ooooyeahhhh' }
    confirmed_at { Time.now }
    confirmation_sent_at { Time.now }
    accept_terms { true }
    phone_token { nil }
    phone_token_validity { nil }
    phone_password_reset_count { 0 }
    last_phone_password_reset { 10.days.ago }

    factory :student, class: 'Users::Student', parent: :user do
      type { 'Users::Student' }

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
      factory :student_with_class_room_3e, class: 'Users::Student', parent: :student do
        class_room { create(:class_room, school: school, school_track: 'troisieme_generale') }
      end
      trait :not_precised do
        gender { 'np' }
      end
      trait :registered_with_phone do
        email { nil }
        phone { '+330637607756' }
      end
    end

    factory :employer, class: 'Users::Employer', parent: :user do
      type { 'Users::Employer' }
    end

    factory :god, class: 'Users::God', parent: :user do
      type { 'Users::God' }
    end

    factory :school_manager, class: 'Users::SchoolManagement', parent: :user do
      school
      type { 'Users::SchoolManagement' }
      role { Users::SchoolManagement.roles[:school_manager] }

      sequence(:email) { |n| "ce.#{"%07d" % n}X@#{school.email_domain_name}" }
    end

    factory :main_teacher, class: 'Users::SchoolManagement', parent: :user do
      type { 'Users::SchoolManagement' }
      role { 'main_teacher' }

      first_name { 'Madame' }
      last_name { 'Labutte' }
    end

    factory :teacher, class: 'Users::SchoolManagement', parent: :user do
      type { 'Users::SchoolManagement' }
      role { 'teacher' }
    end

    factory :other, class: 'Users::SchoolManagement', parent: :user do
      type { 'Users::SchoolManagement' }
      role { 'other' }
    end

    factory :statistician, class: 'Users::Statistician', parent: :user do
      type { 'Users::Statistician' }
      before(:create) do |user|
        create(:statistician_email_whitelist, email: user.email, zipcode: '60', user: user)
      end
    end

    factory :ministry_statistician, class: 'Users::MinistryStatistician', parent: :user do
      transient do
        white_list { create(:ministry_statistician_email_whitelist) }
      end
      type { 'Users::MinistryStatistician' }
      email { white_list.email }
      ministry_id { white_list.group.id }
    end

    factory :user_operator, class: 'Users::Operator', parent: :user do
      type { 'Users::Operator' }
      operator
      api_token { SecureRandom.uuid }
    end


    #
    # Users::Student specific traits
    #
    # traits to create a student[with a school] having a specific class_rooms
    trait :troisieme_generale do
      class_room { build(:class_room, :troisieme_generale, school: school) }
    end

    trait :troisieme_segpa do
      class_room { build(:class_room, :troisieme_segpa, school: school) }
    end

    trait :troisieme_prepa_metiers do
      class_room { build(:class_room, :troisieme_prepa_metiers, school: school) }
    end
    trait :bac_pro do
      class_room { build(:class_room, :bac_pro, school: school) }
    end
  end
end
