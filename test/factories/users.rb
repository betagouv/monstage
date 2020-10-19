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

      school { create(:school) }
      trait :male do
        gender { 'm' }
      end
      trait :female do
        gender { 'f' }
      end
    end

    factory :employer, class: 'Users::Employer', parent: :user do
      type { 'Users::Employer' }
    end

    factory :god, class: 'Users::God', parent: :user do
      type { 'Users::God' }
    end

    factory :school_manager, class: 'Users::SchoolManagement', parent: :user do
      type { 'Users::SchoolManagement' }
      role { Users::SchoolManagement.roles[:school_manager] }

      sequence(:email) { |n| "jean#{n}-claude@ac-dus.fr" }
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
        create(:email_whitelist, email: user.email, zipcode: '60', user: user)
      end
    end

    factory :user_operator, class: 'Users::Operator', parent: :user do
      type { 'Users::Operator' }
      operator { create(:operator) }
      api_token { SecureRandom.uuid }
    end
  end
end
