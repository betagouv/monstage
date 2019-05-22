FactoryBot.define do
  factory :user do
    first_name { 'Jean Claude' }
    last_name { 'Dus' }
    sequence(:email) {|n| "jean#{n}-claude@dus.fr" }
    password { 'ooooyeahhhh' }
    confirmed_at { Time.now }

    factory :student, class: 'Users::Student', parent: :user do
      type { 'Users::Student' }

      first_name { 'Rick' }
      last_name { 'Roll' }
      gender { 'm' }
      birth_date { 14.years.ago }
      has_parental_consent { true }

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

    factory :school_manager, class: 'Users::SchoolManager', parent: :user do
      sequence(:email) {|n| "jean#{n}-claude@ac-dus.fr" }
      type { 'Users::SchoolManager' }
    end

    factory :main_teacher, class: 'Users::MainTeacher', parent: :user do
      type { 'Users::MainTeacher' }
      first_name { 'Madame' }
      last_name { 'Labutte' }
    end

    factory :teacher, class: 'Users::Teacher', parent: :user do
    end

    factory :other, class: 'Users::Other', parent: :user do
    end

    factory :user_operator, class: 'Users::Operator', parent: :user do
      operator { create(:operator) }
    end
  end
end
