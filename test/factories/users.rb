FactoryBot.define do
  factory :user do
    first_name { 'Jean Claude' }
    last_name { 'Dus' }
    sequence(:email) {|n| "jean#{n}-claude@dus.fr" }
    password { 'ooooyeahhhh' }
    confirmed_at { Time.now }

    factory :student, class: 'Users::Student', parent: :user do
      type { 'Users::Student' }
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
  end
end
