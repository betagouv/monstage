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

    # Student
    factory :student, class: 'Users::Student', parent: :user do
      type { 'Users::Student' }

      first_name { FFaker::NameFR.first_name.capitalize  }
      last_name { FFaker::NameFR.last_name.capitalize }
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

      trait :registered_with_phone do
        email { nil }
        phone { '+330637607756' }
      end

      factory :student_with_class_room_3e, class: 'Users::Student', parent: :student do
        class_room { create(:class_room, school: school) }
        after(:create) do |student|
          create(:main_teacher, class_room: student.class_room, school: student.school)
        end
      end
    end

    trait :with_current_area do
      after(:create) do |user|
        area = create(:area, employer_id: user.id, name: FFaker::Lorem.word)
        user.current_area = area
        user.save
      end
    end

    # Employer
    factory :employer,
            class: 'Users::Employer',
            traits: %i[with_current_area] ,
            parent: :user do
      type { 'Users::Employer' }
      employer_role { 'PDG' }
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
      school
      type { 'Users::SchoolManagement' }
      role { 'main_teacher' }

      first_name { 'Madame' }
      last_name { 'Labutte' }

      sequence(:email) { |n| "labutte.#{n}@#{school.email_domain_name}" }
    end

    factory :teacher, class: 'Users::SchoolManagement', parent: :user do
      school
      type { 'Users::SchoolManagement' }
      role { 'teacher' }

      sequence(:email) { |n| "labotte.#{n}@#{school.email_domain_name}" }
    end

    factory :other, class: 'Users::SchoolManagement', parent: :user do
      school
      type { 'Users::SchoolManagement' }
      role { 'other' }

      sequence(:email) { |n| "lautre.#{n}@#{school.email_domain_name}" }
    end

    factory :admin_officer, class: 'Users::SchoolManagement', parent: :user do
      school
      type { 'Users::SchoolManagement' }
      role { 'admin_officer' }

      sequence(:email) { |n| "resp_admin.#{n}@#{school.email_domain_name}" }
    end

    factory :cpe, class: 'Users::SchoolManagement', parent: :user do
      school
      type { 'Users::SchoolManagement' }
      role { 'cpe' }

      sequence(:email) { |n| "cpe.#{n}@#{school.email_domain_name}" }
    end

    factory :statistician,
            class: 'Users::PrefectureStatistician',
            traits: %i[with_current_area],
            parent: :user do
      type { 'Users::PrefectureStatistician' }
      agreement_signatorable { false }
      department { '60' }
      statistician_validation { true }
      before(:create) do |user|
        create(:statistician_email_whitelist, email: user.email, zipcode: '60', user: user)
      end
    end

    factory :prefecture_statistician,
            class: 'Users::PrefectureStatistician',
            traits: %i[with_current_area],
            parent: :user do
      type { 'Users::PrefectureStatistician' }
      agreement_signatorable { false }
      statistician_validation { true }
      before(:create) do |user|
        create(:statistician_email_whitelist, email: user.email, zipcode: '60', user: user)
      end
    end

    factory :education_statistician,
            traits: %i[with_current_area],
            parent: :user,
            class: 'Users::EducationStatistician' do
      type { 'Users::EducationStatistician' }
      agreement_signatorable { false }
      statistician_validation { true }
      department { '60' }
      before(:create) do |user|
        create(:education_statistician_email_whitelist, email: user.email, zipcode: '60', user: user)
      end
    end

    factory :ministry_statistician,
            traits: %i[with_current_area],
            parent: :user,
            class: 'Users::MinistryStatistician' do
      type { 'Users::MinistryStatistician' }
      agreement_signatorable { false }
      statistician_validation { true }
      groups { [create(:group, is_public: true), create(:group, is_public: true)] }
    end

    factory :user_operator,
            traits: %i[with_current_area],
            parent: :user,
            class: 'Users::Operator' do
      type { 'Users::Operator' }
      operator
      api_token { SecureRandom.uuid }

      trait :fully_authorized do
        after(:create) do |user|
          user.operator.update(api_full_access: true)
        end
      end
    end


    #
    # Users::Student specific traits
    #
    # traits to create a student[with a school] having a specific class_rooms
    trait :troisieme_generale do
      class_room { build(:class_room, school: school) }
    end
  end
end
